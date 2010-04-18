function editInGWW() {
  var match = /^http:\/\/www.flickr.com\/photos\/[^/]+\/\d+/.exec(window.location);
  if (match != null) {
    window.location = "http://guesswheresf.org/photos/edit_in_gww?from=" +
      encodeURIComponent(window.location);
  } else {
    match = /^(http:\/\/[^/]+\/photos\/)show(\/\d+)/.exec(window.location);
    if (match != null) {
      window.location = match[1] + 'edit' + match[2];
    } else {
      alert('Try it on a Flickr photo page.');
    }
  }
  return false;
}
editInGWW();
