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
        GWW.map.createMarker(photos[i].photo, '+', loadInfoWindow);
      }

    }

  };

  var loadInfoWindow = function (photo, marker) {
    return function () {
      new Ajax.Request('/photos/' + photo.id + '/map_post', {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: GWW.map.openInfoWindow(marker)
      });
    };
  };

  return publicMethods;
})();
GWW.photosMap.registerOnLoad();
