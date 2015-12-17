function getTitle() {
    return encodeURIComponent(document.title);
}

function getLink() {
    return encodeURIComponent(window.location.href);
}

function shareOnFacebook() {
    var redirect = encodeURIComponent(window.location.origin + "/share/facebook_redirect");
    var url = "https://www.facebook.com/dialog/share?app_id=463153123877346&display=popup&caption=" + getTitle() + "&href=" + getLink() + "&redirect_uri=" + redirect;
    shareOnSocial(url);
}

function shareOnTwitter() {
    // https://twitter.com/home?status=[TWEET]
    var url = "https://twitter.com/home?status=" + getLink();
    shareOnSocial(url);
}

function shareOnGooglePlus() {
    // https://plus.google.com/share?url=[URL]
    var url = "https://plus.google.com/share?url=" + getLink();
    shareOnSocial(url);
}

function shareOnEmail() {
    // mailto:[EMAILED]?subject=[SUBJECT]&body=[BODY]
    var url = "mailto:?subject=" + getTitle() + "&body=Check out Gogether!%0A" + getLink();
    shareWindow = shareOnSocial(url);
    if (shareWindow) {
        shareWindow.close();
    }
}

function shareOnTumblr() {
    // http://www.tumblr.com/share/link?posttype=[text|photo|link|quote|chat|video]&url=[URL]&name=[TITLE]&content=[CONTENT]
    var url = "http://www.tumblr.com/share/link?posttype=link&url=" + getLink() + "&name=" + getTitle() + "&content=" + getLink();
    shareOnSocial(url);
}

function shareOnPinterest() {
    // https://pinterest.com/pin/create/button/?url=[URL]&media=[IMAGEURL]&description=[DESCRIPTION]
    var image = encodeURIComponent($('.swiper-slide-active img').attr('src'));
    var url = "http://pinterest.com/pin/create/button/?url=" + getLink() + "&media=" + image + "&description=" + getTitle();
    shareOnSocial(url);
}

function shareOnReddit() {
    // http://www.reddit.com/submit?url=[URL]&title=[TITLE]
    var url = "http://www.reddit.com/submit?url=" + getLink() + "&title=" + getTitle();
    shareOnSocial(url);
}

function shareOnWhatsapp() {
    // href="whatsapp://send?text=The text to share!"
    var url = "whatsapp://send?text=Take a look at this amazing article on MixSpot! " + getLink();
    shareWindow = shareOnSocial(url);
    if (shareWindow) {
        shareWindow.close();
    }
}

function shareOnSocial(url) {
    var width = Math.min(600, window.innerWidth);
    var height = Math.min(400, window.innerHeight);
    var wLeft = window.screenLeft ? window.screenLeft : window.screenX;
    var wTop = window.screenTop ? window.screenTop : window.screenY;
    var _left = wLeft + (window.innerWidth / 2) - (width / 2);
    var _top = wTop + (window.innerHeight / 2) - (height / 2);
    return window.open(url, 'MixSpot', 'toolbar=no, scrollbars=yes, resizable=yes, width=' + width + ', height=' + height + ', left=' + _left + ', top=' + _top);
}
