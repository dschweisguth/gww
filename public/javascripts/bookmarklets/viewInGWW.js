function viewInGWW() {
  if (/^http:\/\/www.flickr.com\/(photos|people)\/[^/]+/.exec(window.location) != null) {
    // Do this asynchronously so Firefox doesn't treat it as a replace.
    // See http://stackoverflow.com/questions/3731888/javascript-redirect-location-href-breaks-the-back-button-unless-settimeout-is
    setTimeout(function() {
      window.location = "http://guesswheresf.org/bookmarklet/show?from=" +
        encodeURIComponent(window.location);
    }, 0);
  } else {
    alert('Try it on a Flickr photo page or a page which belongs to a Flickr user.');
  }
  return false;
}
viewInGWW();
