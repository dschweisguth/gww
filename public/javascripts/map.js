function initializeMap() {
  new google.maps.Map($('map_canvas'), {
    zoom: 13,
    center: new google.maps.LatLng(37.755, -122.442112),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
}

Event.observe(window, 'load', function() {
  var script = document.createElement('script');
  script.type = "text/javascript";
  script.src = 'http://maps.google.com/maps/api/js?sensor=false&callback=initializeMap';
  document.body.appendChild(script);
});
