$(document).ready(function() {
    (function() {
        var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        // var serverUrl = "http://129.236.234.56:8080";

        var map;
        var eventsList = [];
        var ne;
        var sw;
        var markers = {};
        var infowindows = {};

        function initiate() {
            if ($.cookie("username") == undefined || $.cookie("username") == "") {
                window.location.href = Flask.url_for('login');
            }
            username = $.cookie("username");
            getUserLocation();
        }

        function getUserLocation() {
            if (navigator.geolocation) {
                browserSupportFlag = true;
                navigator.geolocation.getCurrentPosition(function(position) {
                    var initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                    map = new google.maps.Map(document.getElementById("map-canvas"), {
                        center: initialLocation,
                        zoom: 12
                    });
                    initMarker = new google.maps.Marker({
                        position: initialLocation,
                        map: map,
                        icon: "static/icons/current_location.png"
                    });
                    addChangeListener();
                }, function() {
                    handleNoGeolocation(browserSupportFlag);
                });
            } else {
                browserSupportFlag = false;
                handleNoGeolocation(browserSupportFlag);
            }
        }

        function handleNoGeolocation(errorFlag) {
            if (errorFlag == true) {
                alert("Geolocation service failed.");
                initialLocation = newyork;
            } else {
                alert("Your browser doesn't support geolocation. We've placed you in Siberia.");
                initialLocation = siberia;
            }
            map.setCenter(initialLocation);
        }

        function addChangeListener() {
            google.maps.event.addListener(map, 'bounds_changed', function() {
                getEventsFromServer();
            });
        }

        function generateView() {
            var listHead = '<ul class="list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < eventsList.length; i++) {
                list += '<li class="list-group-item">' +
                            '<div><h3>' + eventsList[i].title + '</h3></div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm detail" id="' + eventsList[i].eventId + '">Detail</button>' +
                                '<button class="btn btn-success btn-sm follow" id="' + eventsList[i].eventId + '">Follow</button>' +
                            '</div>' +
                        '</li>';
                if (eventsList[i].eventId in markers) {
                    continue;
                }
                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(eventsList[i].latitude, eventsList[i].longitude),
                    map: map
                });
                addInfoWindow(marker, eventsList[i]);
                markers[eventsList[i].eventId] = marker;
            }
            $('#sidebar').html(listHead + list + listTail);
            $('.detail').click(function() {
                popUpInfoWindow($(this).attr('id'));
            });
            $('.follow').click(function() {
                followEvent($(this).attr('id'));
            });
        }

        function popUpInfoWindow(id) {
            infowindows[id].open(map, markers[id]);
        }

        function followEvent(id) {
            var queryData = {
                "userName": username,
                "eventId": id
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/followEvent",
                data: queryData
            }).done(function(data) {
                if (data.response == 'success') {
                    swal({
                        title: "Succeed",
                        text: "You have followed the event!",
                        type: "success",
                        timer: 2000
                    });
                } else {
                    swal({
                        title: "Failed",
                        text: "You already followed this event",
                        type: "warning",
                        timer: 2000
                    });
                }
            });
        }

        function getEventsFromServer() {
            ne = map.getBounds().getNorthEast();
            sw = map.getBounds().getSouthWest();
            var queryData = {
                "left": sw.lng(),
                "bottom": sw.lat(),
                "right": ne.lng(),
                "top": ne.lat(),
                "timeslot": $("#time-select").val(),
                "currentTime": new Date().getTime(),
                "category": $("#category-select").val()
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/searchEvent",
                data: queryData
            }).done(function(data) {
                var ids = [];
                for (var j = 0; j < data.length; j++) {
                    ids[j] = data[j].eventId;
                }
                for (var i = 0; i < eventsList.length; i++) {
                    var id = eventsList[i].eventId;
                    if (ids.indexOf(id) == -1) {
                        markers[id].setMap(null);
                        delete markers[id];
                    }
                }
                eventsList = data;
                generateView();
            });
        }

        function addInfoWindow(marker, data) {
            var queryData = {
                "eventId": data.eventId
            };
            var userList = "None";
            $.ajax({
                type: "GET",
                url: serverUrl + "/findUserByEvent",
                data: queryData
            }).done(function(users) {
                if (users != undefined) {
                    userList = "";
                    for (var i = 0; i < users.length; i++) {
                        if (i == users.length - 1) {
                            userList += users[i];
                        }
                        else userList += users[i] + ", ";
                    }
                    if (userList == "") {
                        userList = "None"
                    }
                }
                var organizer = data.organizerName;
                if (organizer == "facebook") organizer = "Facebook Event";
                var infoWindow = new google.maps.InfoWindow({
    				content: '<div class="infoWindow">' +
                                '<div><h3>' + data.title + '</h3></div>' +
                                '<div class="infowindow-content"><h4>' + data.description + '</h4></div>' +
                                '<div class="infowindow-content"><h5>From</h5><h4>' + new Date(data.startTime) + '</h4><h5>To</h5><h4>' + new Date(data.endTime) + '</h4></div>' +
                                '<div class="infowindow-content"><h5>Organizer</h5><h4>' + organizer + '</h4></div>' +
                                '<div class="infowindow-content"><h5>Followers</h5><h4>' + userList + '</h4></div>' +
                             '</div>'
    			});
    			google.maps.event.addListener(marker, 'click', function () {
    				infoWindow.open(map, marker);
    			});
                infowindows[data.eventId] = infoWindow;
            });
		}

        $("#search-button").click(function() {
            getEventsFromServer();
        });
        google.maps.event.addDomListener(window, 'load', initiate);

    })();
});
