GWW = {};
GWW.map = (function () {
  var map = null;
  var infoWindow = null;
  
  var publicMethods = {

    registerOnLoad: function (callbackName) {
      Event.observe(window, 'load', function() {
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=' + callbackName;
        document.body.appendChild(script);
      });
    },

    mapsAPIIsLoadedCallback: function () {
      this.map = new google.maps.Map($('map_canvas'), {
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
      }).setMap(this.map);

      this.infoWindow = new google.maps.InfoWindow();

    },

    createMarker: function (photo) {
      var marker = new google.maps.Marker({
        map: this.map,
        position: new google.maps.LatLng(photo.latitude, photo.longitude),
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + encodeURIComponent(photo.symbol) + '|' + photo.color + '|000000'
      });
      google.maps.event.addListener(marker, 'click', loadInfoWindow(photo, marker));
      return marker;
    },

    openInfoWindow: function (marker) {
      return function (transport) {
        GWW.map.infoWindow.setContent(transport.responseText);
        GWW.map.infoWindow.open(GWW.map.map, marker);
      }
    }

  };

  var loadInfoWindow = function (photo, marker) {
    return function () {
      new Ajax.Request('/photos/' + photo.id + '/map_popup', {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: GWW.map.openInfoWindow(marker)
      });
    };
  };

  return publicMethods;
})();
