Event.observe(window, 'load', function() {
  var map = new google.maps.Map($('map_canvas'), {
    zoom: 13,
    center: new google.maps.LatLng(37.755, -122.442112),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
});
