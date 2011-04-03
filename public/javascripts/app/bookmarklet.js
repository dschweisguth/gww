// http://juhukinners.wordpress.com/2009/01/08/how-to-write-a-bookmarklet/
(function () {

  $(function() {
    $('#bookmarklet').attr('href', 'javascript:(' + loadBookmarklet.toString() + ')();');
  });

  var loadBookmarklet = function () {
    var script = document.createElement('script');
    script.src = 'http://guesswheresf.org/javascripts/bookmarklets/viewInGWW.js';
    script.type = 'text/javascript';
    document.body.appendChild(script);
  };

})();
