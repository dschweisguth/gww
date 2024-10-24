GWW.shared.autocomplete = (function () {
  "use strict";

  return {
    setUp: setUp
  };

  function setUp() {
    $("#username").autocomplete({
      source: function (request, response) {
        $.getJSON(
          '/autocompletions/' + encodeURIComponent(request.term),
          {},
          response
        );
      },
      minLength: 0,
      open: function () {
        $(this).autocomplete('widget').css('z-index', 100);
        return false;
      }
    });
  }

}());
$(GWW.shared.autocomplete.setUp);
