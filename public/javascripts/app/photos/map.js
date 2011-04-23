GWW.photosMap = (function () {
  var map = GWW.map();

  var that = {

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback();
    }

  };

  map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
  return that;
})();
