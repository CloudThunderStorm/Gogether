$(document).ready(function() {
    (function() {
        $('#log-in-button').click(function() {
            var uname = $('#log-in-username').val();
            var upass = $('#log-in-password').val();
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
                $.cookie("username", $("#log-in-username").val());
                window.location.href = Flask.url_for('index');
            } else {
                swal("Alert", "Please input proper username and password", "warning");
            }
        });
    })();
});
