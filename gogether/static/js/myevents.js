$(document).ready(function() {
    (function() {
        var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        var map;
        var organizeList = [];
        var followList = [];
        var username;

        function initiate() {
            if ($.cookie("username") == undefined || $.cookie("username") == "") {
                window.location.href = Flask.url_for('loginsignup');;
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
                url: serverUrl + "/findFollowedEvent",
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
                list += '<li class="list-group-item"><div class="events-list-item">' +
                            '<div class="event-title">' + organizeList[i].title + '</div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-danger btn-sm delete-button" id="' + organizeList[i].eventId + '">Delete</button>' +
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
            $('.delete-button').click(function() {
                deleteEvent($(this).attr('id'));
            });
        }

        function generateFollowList() {
            var listHead = '<ul class="nav list-group">';
            var listTail = '</ul>';
            var list = '';
            for (i = 0; i < organizeList.length; i++) {
                list += '<li class="list-group-item"><div class="events-list-item">' +
                            '<div class="event-title">' + organizeList[i].title + '</div>' +
                            '<div class="btn-group" role="group">' +
                                '<button class="btn btn-primary btn-sm unfollow-button" id="' + organizeList[i].eventId + '">Unfollow</button>' +
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
            $('.unfollow-button').click(function() {
                unFollowEvent($(this).attr('id'));
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

        function deleteEvent(id) {
            var queryData = {
                "eventId": id
            };
            $.ajax({
                type: "GET",
                url: serverUrl + "/deleteEventByMobile",
                data: queryData,
            }).done(function(data) {
                if (data.response == 'success') {
                    swal({
                        title: "Succeed",
                        text: "You have deleted the event!",
                        type: "success",
                        timer: 2000
                    });
                } else {
                    swal({
                        title: "Failed",
                        text: "Server is failed to delete your event please try again later",
                        type: "warning",
                        timer: 2000
                    });
                }
            });
        }

        function unFollowEvent(id) {
            var queryData = {
                "evnetId": id,
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
