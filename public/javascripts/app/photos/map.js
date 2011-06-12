GWW.photos = {};
GWW.photos.map = (function () {
  var map = GWW.shared.createMap();

  return {

    setUp: function () {
      map.setUp('GWW.photos.map.mapsAPIIsLoadedCallback');
    },

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback();
    }

  };

})();
