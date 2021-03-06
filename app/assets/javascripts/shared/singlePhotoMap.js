GWW.shared.singlePhotoMap = (function () {
  "use strict";

  return {
    setUp: function () {
      var script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = 'https://maps.google.com/maps/api/js?v=3&key=' + GWW.config.api_key + '&callback=GWW.shared.singlePhotoMap.mapsAPIIsLoadedCallback';
      document.body.appendChild(script);
    },

    mapsAPIIsLoadedCallback: function () {
      var photo = GWW.config.photo;
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
        icon: 'https://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + encodeURIComponent(photo.symbol) + '|' + photo.color + '|000000',
        symbol: photo.symbol
      });
    }

  };

}());
