GWW.people = {};
GWW.people.map = (function () {
  var that = GWW.shared.createMap();

  var superSetUp = GWW.superior(that, 'setUp');
  that.setUp = function () {
    superSetUp('GWW.people.map.mapsAPIIsLoadedCallback');
  };

  var superMapsAPIIsLoadedCallback = GWW.superior(that, 'mapsAPIIsLoadedCallback');
  that.mapsAPIIsLoadedCallback = function () {
    superMapsAPIIsLoadedCallback();
    addToggleHandler('guesses', function (symbol) { return symbol === '!'; });
    addToggleHandler('posts', function (symbol) { return symbol !== '!'; });
  };

  var addToggleHandler = function (id, matcher) {
    $('#' + id).click(toggle(matcher));
  };

  var toggle = function (matcher) {
    return function (event) {
      var markerParent = this.checked ? that.map : null;
      $.each(that.markers, function (i, marker) {
        if (matcher(marker.symbol)) {
          marker.setMap(markerParent);
        }
      });
    }
  };

  return that;
})();
