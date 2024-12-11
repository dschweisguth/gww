// https://juhukinners.wordpress.com/2009/01/08/how-to-write-a-bookmarklet/
(function () {
  "use strict";

  $(function() {
    $('#bookmarklet').attr('href', `javascript:(${loadBookmarklet.toString()})();`);
  });

  const loadBookmarklet = function () {
    const script = document.createElement('script');
    script.src = '//guesswheresf.org/javascripts/bookmarklets/editInGWW.js';
    script.type = 'text/javascript';
    document.body.appendChild(script);
  };

}());
