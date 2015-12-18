$(document).ready(function() {
    (function() {
        // var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        var serverUrl = "http://129.236.234.206:8080";
        var map;
        var datetimepicker1 = $('#datetimepicker1');
        var datetimepicker2 = $('#datetimepicker2');
        var userMarker = null;
        var initMarker = null;

        var title = null;
        var category = null;
        var description = null;
        var startDate = null;
        var endDate = null;

        infobox = $('#infobox');

        function initiate() {
            if ($.cookie("username") == undefined || $.cookie("username") == "") {
                window.location.href = Flask.url_for('login');;
            }
            username = $.cookie("username");
            getUserLocation();
            datetimepicker1.datetimepicker();
            datetimepicker2.datetimepicker();
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

        google.maps.event.addDomListener(window, 'load', initiate);

        $("#location-button").click(function() {
            infobox.text("Please place your maker");
            google.maps.event.addListener(map, 'click', function(event) {
                placeUserMarker(event.latLng);
            });
        });

        function placeUserMarker(location) {
            if (userMarker != null) {
                userMarker.setMap(null);
            }
            userMarker = new google.maps.Marker({
                position: location,
                map: map
            });
            google.maps.event.clearListeners(map);
            infobox.text("Click button to reset place");
        }

        $("#submit-button").click(function() {
            if (getValidData()) {
                createData = {
                    "title": title,
                    "eventId": 0,
                    "category": category,
                    "description": description,
                    "longitude": userMarker.position.lng(),
                    "latitude": userMarker.position.lat(),
                    "organizerName": "zhilei",
                    "startTime": startDate,
                    "endTime": endDate,
                };
                $.ajax({
                    type: "POST",
                    contentType: "application/json",
                    url: serverUrl + "/addEvent",
                    data: JSON.stringify(createData),
                    dataType: "json"
                }).done(function(data) {
                    if (data.response == 'success') {
                        swal({
                            title: "Succeed",
                            text: "Your event is created!",
                            type: "success",
                            timer: 2000
                        });
                    } else {
                        swal({
                            title: "Failed",
                            text: "Server is failed to create your event please try again later",
                            type: "warning",
                            timer: 2000
                        });
                    }
                });
            }
        });

        function getValidData() {
            title = document.getElementById('title').value;
            category = document.getElementById('category-select').value;
            description = document.getElementById('description').value;
            if (datetimepicker1.data("DateTimePicker").date() != null) {
                startDate = datetimepicker1.data("DateTimePicker").date().toDate().getTime();
            }
            if (datetimepicker2.data("DateTimePicker").date() != null) {
                endDate = datetimepicker2.data("DateTimePicker").date().toDate().getTime();
            }
            if (title == null || title.length == 0) {
                swal("Alert!", "Please add title!", "warning");
                return false;
            }
            if (category == null) {
                swal("Alert!", "Please select category!", "warning");
                return false;
            }
            if (description == null || description.length == 0) {
                swal("Alert!", "Please add description!", "warning");
                return false;
            }
            if (startDate == null) {
                swal("Alert!", "Please add start date!", "warning");
                return false;
            }
            if (endDate == null) {
                swal("Alert!", "Please add end date!", "warning");
                return false;
            }
            if (startDate >= endDate) {
                swal("Alert!", "End date has to be later than start date!", "warning");
                return false;
            }
            if (userMarker == null || userMarker.position == undefined) {
                swal("Alert!", "Please place the marker of your event", "warning");
                return false;
            }
            return true;
        }
    })();
});
