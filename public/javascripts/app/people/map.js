GWW = {};
GWW.userMap = (function () {
  var map = null;
  var guesses = [];
  var posts = [];
  var infoWindow = null;

  var publicMethods = {

    registerOnLoad: function () {
      Event.observe(window, 'load', function() {
        var script = document.createElement('script');
        script.type = "text/javascript";
        script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=GWW.userMap.mapsAPIIsLoadedCallback';
        document.body.appendChild(script);
      });
    },

    mapsAPIIsLoadedCallback: function () {
      map = new google.maps.Map($('map_canvas'), {
        zoom: 13,
        center: new google.maps.LatLng(37.76, -122.442112),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });

      new google.maps.Polyline({
        path: [
          new google.maps.LatLng(37.831853, -122.472668),
          new google.maps.LatLng(37.852543, -122.418787),
          new google.maps.LatLng(37.92944,  -122.432027),
          new google.maps.LatLng(37.885151, -122.376194),
          new google.maps.LatLng(37.811411, -122.345982),
          new google.maps.LatLng(37.708333, -122.281437),
          new google.maps.LatLng(37.708333, -122.557983),
          new google.maps.LatLng(37.815209, -122.584505),
          new google.maps.LatLng(37.815209, -122.529659)
        ],
        strokeColor: '#FF6600',
        strokeOpacity: 1.0,
        strokeWeight: 2
      }).setMap(map);

      var photos = GWW.config;
      infoWindow = new google.maps.InfoWindow();
      for (var i = 0; i < photos.length; i++) {
        var photo = photos[i].photo;
        var marker = new google.maps.Marker({
          map: map,
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
      infoWindow.open(map, marker);
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
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(this.checked ? map : null);
      }
    }
  };

  return publicMethods;
})();
GWW.userMap.registerOnLoad();
