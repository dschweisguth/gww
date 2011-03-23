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

      $('guesses').observe('click', toggleMarkers('guesses', guesses));
      $('posts').observe('click', toggleMarkers('posts', posts));

    }

  };

  var loadInfoWindow = function (marker, photo) {
    return function () {
      new Ajax.Request(window.location + '/' + photo.id + '/' + photo.pin_type, {
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

  var toggleMarkers = function (id, list) {
    return function (event) {
      var checkboxIsChecked = $(id).checked
      for (var i = 0; i < list.length; i++) {
        list[i].setMap(checkboxIsChecked ? map : null);
      }
    }
  };

  return publicMethods;
})();
GWW.userMap.registerOnLoad();
