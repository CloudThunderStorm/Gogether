$(document).ready(function() {
    (function() {
        var map;
        var eventsList = [];
        var ne;
        var sw;

        function initiate() {
            if ($.cookie("username") == undefined) {
                window.location="login.html";
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
                        zoom: 15
                    });
                    initMarker = new google.maps.Marker({
                        position: initialLocation,
                        map: map,
                        icon: "icons/current_location.png"
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
            console.log(1);
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
            var listHead = '<ul class="nav list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < eventsList.length; i++) {
                list += '<li class="list-group-item"><div class="events-list-item">' +
                            '<div class="event-title">' + eventsList[i].title + '</div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm follow" id="' + eventsList[i].eventId + '">Follow</button>' +
                                '<button class="btn btn-warning btn-sm" id="' + eventsList[i].eventId + '">Share</button>' +
                            '</div>' +
                        '</div></li>';

                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(eventsList[i].latitude, eventsList[i].longitude),
                    map: map
                });
                addInfoWindow(marker, eventsList[i]);
            }
            $('#sidebar').html(listHead + list + listTail);
            $('.follow').click(function() {
                followEvent($(this).attr('id'));
            });
        }

        function followEvent(id) {

        }

        function getEventsFromServer() {
            ne = map.getBounds().getNorthEast();
            sw = map.getBounds().getSouthWest();
            var queryData = {
                "left": sw.lng(),
                "bottom": sw.lat(),
                "right": ne.lng(),
                "top": ne.lat(),
                "timeslot": -1,
                "currentTime": -1
            };
            $.ajax({
                type: "GET",
                url: "http://129.236.235.98:8080/searchEvent",
                data: queryData,
            }).done(function(data) {
                eventsList = data;
                generateView();
            });
        }

        function addInfoWindow(marker, data) {
			var infoWindow = new google.maps.InfoWindow({
				content: '<div class="infoWindow">' +
                            '<div>' + data.description + '</div>' +
                            '<div>' + new Date(data.startTime) + ' - </div><div>' + new Date(data.endTime) + '</div>' +
                         '</div>'
			});
			google.maps.event.addListener(marker, 'click', function () {
				infoWindow.open(map, marker);
			});
		}

        $("#search-button").click(function() {
            alert(document.getElementById("category-select").value);
        });
        google.maps.event.addDomListener(window, 'load', initiate);

    })();
});
