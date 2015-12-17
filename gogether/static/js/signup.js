$(document).ready(function() {
    (function() {
        $('#sign-up-button').click(function() {
            var uname = $('#sign-up-username').val();
            var upass = $('#sign-up-password').val();
            var urepass = $('#sign-up-re-password').val();
            if (uname != undefined && uname != "" && upass != undefined && upass != "") {
                // var queryData = {
                //     "username": uname,
                //     "password": upass
                // };
                // $.ajax({
                //     type: "GET",
                //     url: "localhost:5000/",
                //     data: queryData,
                // }).done(function(data) {
                //
                // });
                $.cookie("username", $("#sign-up-username").val());
                window.location.href = Flask.url_for('index');
            } else {
                swal("Alert", "Please input proper username and password", "warning");
            }
        });
    })();
});
