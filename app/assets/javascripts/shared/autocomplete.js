"use strict";

GWW.shared.autocomplete = (function () {

  return {
    setUp: setUp
  };

  function setUp() {
    $("#username").autocomplete({
      source: function (request, response) {
        $.getJSON(
          '/autocomplete_usernames/' + escape(request.term),
          {},
          function (data) {
            response($.map(data, function (item) {
              return {
                label: item.username,
                value: item.username
              }
            }));
          }
        );
      },
      minLength: 0,
      open: function () {
        $(this).autocomplete('widget').css('z-index', 100);
        return false;
      }
    });
  }

})();
$(GWW.shared.autocomplete.setUp);
