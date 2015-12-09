$(document).ready(function() {
    (function() {
        $('#submit-button').click(function() {
            if ($('#username').val() != undefined) {
                $.cookie("username", $('#username').val());
                window.location = "index.html";
            }
        });
    })();
});
