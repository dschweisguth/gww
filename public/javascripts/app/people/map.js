GWW.personMap = (function () {
  var map = GWW.map();

  var that = {

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

  map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
  return that;
})();
