GWW.photosMap = (function () {
  var map = null;

  var publicMethods = {

    registerOnLoad: function () {
      GWW.map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
    },

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        GWW.map.createMarker(photos[i].photo, '+', loadInfoWindow, infoWindowContentPath);
      }

    }

  };

  var infoWindowContentPath = function (photo) {
    return '/photos/' + photo.id + '/map_post';
  };

  var loadInfoWindow = function (photo, marker, infoWindowContentPath) {
    return function () {
      new Ajax.Request(infoWindowContentPath(photo), {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: GWW.map.openInfoWindow(marker)
      });
    };
  };

  return publicMethods;
})();
GWW.photosMap.registerOnLoad();
