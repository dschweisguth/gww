function editInGWW() {
  var match = /^http:\/\/www.flickr.com\/photos\/[^/]+\/\d+/.exec(window.location);
  if (match == null) {
    alert('Try it on a Flickr photo page.')
  } else {
    window.location = "http://guesswheresf.org/photos/edit_in_gww?from=" +
      encodeURIComponent(window.location)
  }
}
editInGWW();
