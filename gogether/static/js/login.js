$(document).ready(function() {
    (function() {
        var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
        // var serverUrl = "http://129.236.234.56:8080";
        $('#log-in-button').click(function() {
            var uname = $('#log-in-username').val();
            var upass = $('#log-in-password').val();
            if (uname != undefined && uname != "" && upass != undefined && upass != "") {
                var queryData = {
                    "userName": uname,
                    "password": upass
                };
                $.ajax({
                    type: "GET",
                    url: serverUrl + "/login",
                    data: queryData,
                }).done(function(data) {
                    if (data.response == "success") {
                        $.cookie("username", $("#log-in-username").val());
                        window.location.href = Flask.url_for('index');
                    } else {
                        swal("Alert", "Please input correct username and password", "warning");
                    }
                });
            } else {
                swal("Alert", "Please input correct username and password", "warning");
            }
        });
    })();
});
