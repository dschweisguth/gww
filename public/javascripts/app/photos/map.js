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
        var photo = photos[i].photo;
        var marker = new google.maps.Marker({
          map: GWW.map.map,
          position: new google.maps.LatLng(photo.latitude, photo.longitude),
          icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=+|' + photo.pin_color + '|000000'
        });
        google.maps.event.addListener(marker, 'click', loadInfoWindow(marker, photo));
      }

    }

  };

  var loadInfoWindow = function (marker, photo) {
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
