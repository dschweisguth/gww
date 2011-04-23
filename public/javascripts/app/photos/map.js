GWW.photosMap = (function () {
  var map = GWW.map();
  var markers = [];

  var that = {

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback(showMarkers);
    }

  };

  var showMarkers = function (photos) {
    map.jsonIncludedAllMarkers = ! photos.partial;
    map.jsonBounds = photos.bounds;
    map.removeMarkers(markers);
    $.each(photos.photos, function (i, photo) {
      markers.push(map.createMarker(photo));
    })
  };

  map.registerOnLoad('GWW.photosMap.mapsAPIIsLoadedCallback');
  return that;
})();
