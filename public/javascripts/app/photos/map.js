GWW.photosMap = (function () {
  var map = GWW.map();

  var that = {

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        map.createMarker(photos[i].photo);
      }

    }

  };

  map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
  return that;
})();
