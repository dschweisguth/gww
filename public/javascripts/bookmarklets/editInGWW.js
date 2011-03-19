function editInGWW() {
  if (/^http:\/\/www.flickr.com\/photos\/[^/]+\/\d+/.exec(window.location) != null) {
    // Do this asynchronously so Firefox doesn't treat it as a replace.
    // See http://stackoverflow.com/questions/3731888/javascript-redirect-location-href-breaks-the-back-button-unless-settimeout-is
    setTimeout(function() {
      window.location = "http://guesswheresf.org/admin/photos/edit_in_gww?from=" +
        encodeURIComponent(window.location);
    }, 0);
  } else {
    var match = /^(http:\/\/[^/]+\/)photos\/show(\/\d+)/.exec(window.location);
    if (match != null) {
      setTimeout(function() {
        window.location = match[1] + 'admin/photos' + match[2] + '/edit' ;
      }, 0);
    } else {
      alert('Try it on a Flickr or GWW photo page.');
    }
  }
  return false;
}
editInGWW();
