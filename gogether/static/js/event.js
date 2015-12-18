$(document).ready(function() {
    (function() {
        // var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        var serverUrl = "http://129.236.234.206:8080";
        var username;
        var eventId;
        var eventInfo;
        var map;

        function initiate() {
            if ($.cookie("username") == undefined || $.cookie("username") == "") {
                window.location.href = Flask.url_for('login');;
            }
            username = $.cookie("username");
            eventId = $("#event-id").attr("value");
        }

        function getEventInfo() {
            var queryData = {
                "eventId": evnetId
            };
            $.ajax({
                type: "GET",
                crossDomain: true,
                dataType: 'json',
                url: serverUrl + "/getEventById",
                data: queryData
            }).done(function(data) {
                eventInfo = data;
            });
        }
        function displayInfo() {

        }
        google.maps.event.addDomListener(window, 'load', initiate);
    })();
});
