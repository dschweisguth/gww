GWW.personMap = (function () {
  var map = GWW.map();
  var guesses = [];
  var posts = [];

  var that = {

    mapsAPIIsLoadedCallback: function () {
      map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        var photo = photos[i].photo;
        var marker = map.createMarker(photo);
        (photo.symbol === '!' ? guesses : posts).push(marker);
      }

      addToggleHandler('guesses', guesses);
      addToggleHandler('posts', posts);

    }

  };

  var addToggleHandler = function (id, markers) {
    var checkbox = $(id);
    if (checkbox) {
      checkbox.observe('click', toggle(markers));
    }
  };

  var toggle = function (markers) {
    return function (event) {
      var markerParent = this.checked ? map.map : null;
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(markerParent);
      }
    }
  };

  map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
  return that;
})();
