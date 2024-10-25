GWW.shared.autocompletions = function () {
  "use strict";

  function setUp() {
    GWW.shared.autocomplete("#username", autocompletionsURI);
  }

  function autocompletionsURI(request) {
    return `/autocompletions/${encodeURIComponent(request.term)}`;
  }

  return {
    setUp: setUp
  };

}();
$(GWW.shared.autocompletions.setUp);
