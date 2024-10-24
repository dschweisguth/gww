GWW.shared.singlePhotoMap = function () {
  "use strict";

  return {
    setUp: function () {
      const script = document.createElement('script');
      script.type = 'text/javascript';
      script.src = `https://maps.googleapis.com/maps/api/js?v=3&libraries=marker&key=${GWW.config.api_key}&callback=GWW.shared.singlePhotoMap.mapsAPIIsLoadedCallback`;
      document.body.appendChild(script);
    },

    mapsAPIIsLoadedCallback: function () {
      const photo = GWW.config.photo;
      const center = new google.maps.LatLng(photo.latitude, photo.longitude);
      const map = new google.maps.Map($('#map')[0], {
        zoom: 15,
        center: center,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        disableDefaultUI: true,
        zoomControl: true,
        mapId: "DEMO_MAP_ID"
      });
      const pin = new google.maps.marker.PinElement({
        background: `#${photo.color}`,
        borderColor: 'black',
        glyph: photo.symbol
      })
      new google.maps.marker.AdvancedMarkerElement({
        map: map,
        position: center,
        content: pin.element
      });
    }

  };

}();
