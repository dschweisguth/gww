var GWW = {
  initializeMap: function () {
    GWW.map = new google.maps.Map($('map_canvas'), {
      zoom: 13,
      center: new google.maps.LatLng(37.755, -122.442112),
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    new Ajax.Request(window.location + '_markers', {
      method: 'get',
      requestHeaders: { Accept: 'application/json' },
      onSuccess: GWW.addMarkers
    });
  },

  addMarkers: function (transport) {
    var guesses = transport.responseText.evalJSON(true);
    for (var i = 0; i < guesses.length; i++) {
      var photo = guesses[i].guess.photo;
      new google.maps.Marker({
        map: GWW.map,
        position: new google.maps.LatLng(photo.latitude, photo.longitude)
      });
    }
  }

};

Event.observe(window, 'load', function() {
  var script = document.createElement('script');
  script.type = "text/javascript";
  script.src = 'http://maps.google.com/maps/api/js?sensor=false&callback=GWW.initializeMap';
  document.body.appendChild(script);
});
