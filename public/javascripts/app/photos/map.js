GWW.photosMap = (function () {
  var publicMethods = {

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        GWW.map.createMarker(photos[i].photo, '+');
      }

    }

  };

  GWW.map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
  return publicMethods;
})();
