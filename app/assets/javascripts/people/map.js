GWW.people = {};
GWW.people.map = function () {
  "use strict";

  var that = GWW.shared.createMap();

  var superSetUp = GWW.shared.superior(that, 'setUp');
  that.setUp = function () {
    superSetUp('GWW.people.map.mapsAPIIsLoadedCallback');
  };

  var superMapsAPIIsLoadedCallback = GWW.shared.superior(that, 'mapsAPIIsLoadedCallback');
  that.mapsAPIIsLoadedCallback = function () {
    superMapsAPIIsLoadedCallback();
    addToggleHandler('guesses', function (symbol) { return symbol === '!'; });
    addToggleHandler('posts', function (symbol) { return symbol !== '!'; });
  };

  var addToggleHandler = function (id, matcher) {
    $('#' + id).click(toggle(matcher));
  };

  var toggle = function (matcher) {
    return function () {
      var markerParent = this.checked ? that.map : null;
      $.each(that.markers, function (i, marker) {
        if (matcher(marker.content.textContent)) {
          marker.setMap(markerParent);
        }
      });
    };
  };

  that.getMarkerParent = function (marker) {
    const guesses = $('#guesses');
    if (guesses.length === 0) {
      return that.map;
    }
    const symbol = marker.content.textContent;
    if (guesses.prop('checked') && symbol === '!' || $('#posts').prop('checked') && symbol !== '!') {
      return that.map;
    }
    return null;
  };

  return that;
}();
