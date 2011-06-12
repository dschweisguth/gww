GWW.people = {};
GWW.people.map = (function () {
  var map = GWW.shared.createMap();

  var that = {

    setUp: function () {
      map.setUp('GWW.people.map.mapsAPIIsLoadedCallback');
    },

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback();
      addToggleHandler('guesses', function (symbol) { return symbol === '!'; });
      addToggleHandler('posts', function (symbol) { return symbol !== '!'; });
    }

  };

  var addToggleHandler = function (id, matcher) {
    $('#' + id).click(toggle(matcher));
  };

  var toggle = function (matcher) {
    return function (event) {
      var markerParent = this.checked ? map.map : null;
      $.each(map.markers, function (i, marker) {
        if (matcher(marker.symbol)) {
          marker.setMap(markerParent);
        }
      });
    }
  };

  return that;
})();
