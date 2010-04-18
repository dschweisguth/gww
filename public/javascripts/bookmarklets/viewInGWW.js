function viewInGWW() {
  var match = /^http:\/\/www.flickr.com\/photos\/[^/]+\/\d+/.exec(window.location);
  if (match != null) {
    window.location = "http://guesswheresf.org/photos/view_in_gww?from=" +
      encodeURIComponent(window.location);
  } else {
    alert('Try it on a Flickr photo page.');
  }
  return false;
}
viewInGWW();
