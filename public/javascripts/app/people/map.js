GWW.personMap = (function () {
  var guesses = [];
  var posts = [];
  var infoWindow = null;

  var publicMethods = {

    registerOnLoad: function () {
      GWW.map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
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
          icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%' +
            (photo.pin_type === 'guess' ? '21' : '3F') + '|' + photo.pin_color + '|000000'
        });
        google.maps.event.addListener(marker, 'click', loadInfoWindow(marker, photo));
        (photo.pin_type === 'guess' ? guesses : posts).push(marker);
      }

      addToggleHandler('guesses', guesses);
      addToggleHandler('posts', posts);

    }

  };

  var loadInfoWindow = function (marker, photo) {
    return function () {
      var path = photo.pin_type == 'guess'
        ? window.location + '/' + photo.id + '/guess'
        : '/photos/' + photo.id + '/map_post';
      new Ajax.Request(path, {
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

  var addToggleHandler = function (id, markers) {
    var checkbox = $(id);
    if (checkbox) {
      checkbox.observe('click', toggle(markers));
    }
  };

  var toggle = function (markers) {
    return function (event) {
      var markerParent = this.checked ? GWW.map.map : null;
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(markerParent);
      }
    }
  };

  return publicMethods;
})();
GWW.personMap.registerOnLoad();
