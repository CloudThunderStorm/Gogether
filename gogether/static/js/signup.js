$(document).ready(function() {
    (function() {
        $('#sign-up-button').click(function() {
            var serverUrl = "http://ec2-52-90-113-155.compute-1.amazonaws.com:8080";
            // var serverUrl = "http://129.236.234.56:8080";
            var uname = $('#sign-up-username').val();
            var upass = $('#sign-up-password').val();
            var urepass = $('#sign-up-re-password').val();
            var udesp = $('#description').val();
            if (upass == urepass) {
                if (uname != undefined && uname != "" && upass != undefined && upass != "" && udesp != undefined && udesp != "") {
                    var queryData = {
                        "name": uname,
                        "password": upass,
                        "userId": 0,
                        "bioImageURL": "test",
                        "description": udesp
                    };
                    $.ajax({
                        type: "POST",
                        dataType: "json",
                        contentType: "application/json",
                        url: serverUrl + "/addUser",
                        data: JSON.stringify(queryData)
                    }).done(function(data) {
                        if (data.response == "success") {
                            $.cookie("username", $("#sign-up-username").val());
                            window.location.href = Flask.url_for('index');
                        }
                    }).fail(function() {
                        swal("Alert", "Fail to create your account", "warning");
                    });
                } else {
                    swal("Alert", "Please input proper username, password and self description", "warning");
                }
            } else {
                swal("Alert", "Please type in the same password when re-entering the password", "warning");
            }
        });
    })();
});
