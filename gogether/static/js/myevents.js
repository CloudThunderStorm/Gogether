$(document).ready(function() {
    (function() {
        var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        // var serverUrl = "http://129.236.234.56:8080";
        var map;
        var organizeList = [];
        var followList = [];
        var username;
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
                    getOrganizedList();
                    getFollowedList();
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

        function getOrganizedList() {
            var queryData = {
                "userName": username
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/findOrganizedEvent",
                data: queryData,
                dataType: "json"
            }).done(function(data) {
                organizeList = data;
                generateOrganizeList();
            }).fail(function() {
                console.log('fail');
            });
        }

        function getFollowedList() {
            var queryData = {
                "userName": username
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/findFollowingEvent",
                data: queryData,
                dataType: "json"
            }).done(function(data) {
                followList = data;
                generateFollowList();
            }).fail(function() {
                console.log('fail');
            });
        }

        function generateOrganizeList() {
            var listHead = '<ul class="nav list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < organizeList.length; i++) {
                list += '<li class="list-group-item">' +
                            '<div class="event-title"><h3>' + organizeList[i].title + '</h3></div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm detail" id="' + organizeList[i].eventId + '">Detail</button>' +
                                '<button class="btn btn-danger btn-sm delete-button" id="' + organizeList[i].eventId + '">Delete</button>' +
                            '</div>' +
                        '</li>';

                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(organizeList[i].latitude, organizeList[i].longitude),
                    map: map
                });
                addInfoWindow(marker, organizeList[i]);
                markers[organizeList[i].eventId] = marker;
            }
            $('#organize-list').html(listHead + list + listTail);
            $('.detail').click(function() {
                popUpInfoWindow($(this).attr('id'));
            });
            $('.delete-button').click(function() {
                deleteEvent($(this).attr('id'));
            });
        }

        function popUpInfoWindow(id) {
            infowindows[id].open(map, markers[id]);
            map.setCenter(markers[i].getPosition());
        }

        function generateFollowList() {
            var listHead = '<ul class="list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < followList.length; i++) {
                list += '<li class="list-group-item">' +
                            '<div class="event-title"><h3>' + followList[i].title + '</h3></div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm follow-detail" id="' + followList[i].eventId + '">Detail</button>' +
                                '<button class="btn btn-warning btn-sm unfollow-button" id="' + followList[i].eventId + '">Unfollow</button>' +
                            '</div>' +
                        '</li>';

                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(followList[i].latitude, followList[i].longitude),
                    map: map
                });
                addInfoWindow(marker, followList[i]);
                markers[followList[i].eventId] = marker;
            }
            $('#follow-list').html(listHead + list + listTail);
            $('.follow-detail').click(function() {
                popUpInfoWindow($(this).attr('id'));
            });
            $('.unfollow-button').click(function() {
                unFollowEvent($(this).attr('id'));
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

        function deleteEvent(id) {
            var queryData = {
                "eventId": id,
                "organizerName": username
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/deleteEvent",
                data: queryData,
            }).done(function(data) {
                if (data.response == 'success') {
                    swal({
                        title: "Succeed",
                        text: "You have deleted the event!",
                        type: "success",
                        timer: 2000
                    });
                    for (var i in markers) {
                        markers[i].setMap(null);
                    }
                    markers = {};
                    getOrganizedList();
                    getFollowedList();
                } else {
                    swal({
                        title: "Failed",
                        text: "Server is failed to delete your event, please try again later",
                        type: "warning",
                        timer: 2000
                    });
                }
            });
        }

        function unFollowEvent(id) {
            var queryData = {
                "eventId": id,
                "userName": username
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/unfollow",
                data: queryData,
            }).done(function(data) {
                if (data.response == 'success') {
                    swal({
                        title: "Succeed",
                        text: "You have unfollowed the event!",
                        type: "success",
                        timer: 2000
                    });
                    for (var i in markers) {
                        markers[i].setMap(null);
                    }
                    markers = {};
                    getFollowedList();
                    getOrganizedList();
                } else {
                    swal({
                        title: "Failed",
                        text: "Server is failed to unfollow the event please try again later",
                        type: "warning",
                        timer: 2000
                    });
                }
            });
        }

        google.maps.event.addDomListener(window, 'load', initiate);
    })();
});
