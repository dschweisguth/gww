GWW.personMap = (function () {
  var map = GWW.map();
  var guesses = [];
  var posts = [];

  var that = {

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback(showMarkers);
      addToggleHandler('guesses', guesses);
      addToggleHandler('posts', posts);
    }

  };

  var showMarkers = function (photos) {
    map.removeMarkers(guesses);
    map.removeMarkers(posts);
    $.each(photos, function (i, photoRef) {
      var photo = photoRef.photo;
      (photo.symbol === '!' ? guesses : posts).push(map.createMarker(photo));
    });
  };

  var addToggleHandler = function (id, markers) {
    $('#' + id).click(toggle(markers));
  };

  var toggle = function (markers) {
    return function (event) {
      var markerParent = this.checked ? map.map : null;
      $.each(markers, function (i, marker) {
        marker.setMap(markerParent);
      });
    }
  };

  map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
  return that;
})();
