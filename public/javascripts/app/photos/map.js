GWW.photosMap = (function () {
  var map = null;
  var guesses = [];
  var posts = [];
  var infoWindow = null;

  var publicMethods = {

    registerOnLoad: function () {
      Event.observe(window, 'load', function() {
        var script = document.createElement('script');
        script.type = "text/javascript";
        script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=GWW.photosMap.mapsAPIIsLoadedCallback';
        document.body.appendChild(script);
      });
    },

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      infoWindow = new google.maps.InfoWindow();
      for (var i = 0; i < photos.length; i++) {
        var photo = photos[i].photo;
        var marker = new google.maps.Marker({
          map: GWW.map.map,
          position: new google.maps.LatLng(photo.latitude, photo.longitude),
          icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=+|' + photo.pin_color + '|000000'
        });
        google.maps.event.addListener(marker, 'click', loadInfoWindow(marker, photo));
        (photo.pin_type === 'guess' ? guesses : posts).push(marker);
      }

    }

  };

  var loadInfoWindow = function (marker, photo) {
    return function () {
      new Ajax.Request('/photos/' + photo.id + '/map_post', {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: openInfoWindow(marker)
      });
    };
  };

  var openInfoWindow = function(marker) {
    return function (transport) {
      infoWindow.setContent(transport.responseText);
      infoWindow.open(GWW.map.map, marker);
    }
  };

  return publicMethods;
})();
GWW.photosMap.registerOnLoad();
