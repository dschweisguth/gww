GWW.photosMap = (function () {
  var publicMethods = {

    registerOnLoad: function () {
      GWW.map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
    },

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        GWW.map.createMarker(photos[i].photo, '+', infoWindowContentPath);
      }

    }

  };

  var infoWindowContentPath = function (photo) {
    return '/photos/' + photo.id + '/map_post';
  };

  return publicMethods;
})();
GWW.photosMap.registerOnLoad();
