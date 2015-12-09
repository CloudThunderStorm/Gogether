$(document).ready(function() {
    (function() {
        var map;
        var organizeList = [];
        var followList = [];
        var username;

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
                url: "http://129.236.235.98:8080/findOrganizedEvent",
                data: queryData,
            }).done(function(data) {
                organizeList = data;
                generateOrganizeList();
            });
        }

        function getFollowedList() {

        }

        function generateOrganizeList() {
            var listHead = '<ul class="nav list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < organizeList.length; i++) {
                list += '<li class="list-group-item"><div class="events-list-item">' +
                            '<div class="event-title">' + organizeList[i].title + '</div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm unfollow" id="' + organizeList[i].eventId + '">Unfollow</button>' +
                                '<button class="btn btn-warning btn-sm" id="' + organizeList[i].eventId + '">Share</button>' +
                            '</div>' +
                        '</div></li>';

                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(organizeList[i].latitude, organizeList[i].longitude),
                    map: map
                });
                addInfoWindow(marker, organizeList[i]);
            }
            $('#organize-list').html(listHead + list + listTail);
            $('.unfollow').click(function() {
                unFollowEvent($(this).attr('id'));
            });
        }

        function generateFollowList() {

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


        function unFollowEvent(id) {

        }

        google.maps.event.addDomListener(window, 'load', initiate);
    })();
});
