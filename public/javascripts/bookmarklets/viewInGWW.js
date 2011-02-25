function viewInGWW() {
  if (/^http:\/\/www.flickr.com\/(photos|people)\/[^/]+/.exec(window.location) != null) {
    window.location = "http://guesswheresf.org/bookmarklet/view?from=" +
      encodeURIComponent(window.location);
  } else {
    alert('Try it on a Flickr photo page or a page which belongs to a Flickr user.');
  }
  return false;
}
viewInGWW();
