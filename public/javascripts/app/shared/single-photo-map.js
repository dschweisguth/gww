var GWW = {};

GWW.singlePhotoMap = (function () {
  var registerOnLoad = function () {
    $(function() {
      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=GWW.singlePhotoMap.mapsAPIIsLoadedCallback';
      document.body.appendChild(script);
    });
  };

  var that = {
    mapsAPIIsLoadedCallback: function () {
      var photo = GWW.config;
      var center = new google.maps.LatLng(photo.latitude, photo.longitude);
      var map = new google.maps.Map($('#map')[0], {
        zoom: 15,
        center: center,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        disableDefaultUI: true,
        zoomControl: true
      });
      new google.maps.Marker({
        map: map,
        position: center,
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + encodeURIComponent(photo.symbol) + '|' + photo.color + '|000000',
        symbol: photo.symbol
      });
    }
  };

  registerOnLoad();
  return that;
})();
