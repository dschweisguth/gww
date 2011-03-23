GWW = {};
GWW.userMap = (function () {
  var map = null;

  var markers = [];

  var addMarkers = function (transport) {
    var photos = transport.responseText.evalJSON(true);
    for (var i = 0; i < photos.length; i++) {
      var photo = photos[i].photo;
      var marker = new google.maps.Marker({
        map: map,
        position: new google.maps.LatLng(photo.latitude, photo.longitude),
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%21|' + photo.pin_color + '|000000'
      });
      markers.push(marker);
    }
    $('guesses').observe('click', hideOrShowMarkers);
  };

  var hideOrShowMarkers = function (event) {
    var checkboxIsChecked = $('guesses').checked
    for (var i = 0; i < markers.length; i++) {
      markers[i].setMap(checkboxIsChecked ? map : null);
    }
  };

  return {

    registerOnLoad: function () {
      Event.observe(window, 'load', function() {
        var script = document.createElement('script');
        script.type = "text/javascript";
        script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=GWW.userMap.initializeMap';
        document.body.appendChild(script);
      });
    },

    initializeMap: function () {
      map = new google.maps.Map($('map_canvas'), {
        zoom: 13,
        center: new google.maps.LatLng(37.76, -122.442112),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
      new Ajax.Request(window.location + '_markers', {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: addMarkers
      });
    }

  };

})();
GWW.userMap.registerOnLoad();
