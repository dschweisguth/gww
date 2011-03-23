var GWW = {
  markers: [],

  initializeMap: function () {
    GWW.map = new google.maps.Map($('map_canvas'), {
      zoom: 13,
      center: new google.maps.LatLng(37.76, -122.442112),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    new Ajax.Request(window.location + '_markers', {
      method: 'get',
      requestHeaders: { Accept: 'application/json' },
      onSuccess: GWW.addMarkers
    });
  },

  addMarkers: function (transport) {
    var photos = transport.responseText.evalJSON(true);
    for (var i = 0; i < photos.length; i++) {
      var photo = photos[i].photo;
      var marker = new google.maps.Marker({
        map: GWW.map,
        position: new google.maps.LatLng(photo.latitude, photo.longitude),
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%21|' + photo.pin_color + '|000000'
      });
      GWW.markers.push(marker);
    }
    var guessesCheckbox = $('guesses');
    guessesCheckbox.observe('click', GWW.hideOrShowMarkers);
  },

  hideOrShowMarkers: function (event) {
    var checkboxIsChecked = $('guesses').checked
    for (var j = 0; j < GWW.markers.length; j++) {
      GWW.markers[j].setMap(checkboxIsChecked ? GWW.map : null);
    }
  }

};

Event.observe(window, 'load', function() {
  var script = document.createElement('script');
  script.type = "text/javascript";
  script.src = 'http://maps.google.com/maps/api/js?sensor=false&callback=GWW.initializeMap';
  document.body.appendChild(script);
});
