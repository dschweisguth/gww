GWW.shared.singlePhotoMap = function () {
  "use strict";

  return {
    setUp: function () {
      GWW.shared.loadGoogleMaps('GWW.shared.singlePhotoMap.mapsAPIIsLoadedCallback');
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
