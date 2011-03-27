GWW.personMap = (function () {
  var guesses = [];
  var posts = [];

  var publicMethods = {

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        var photo = photos[i].photo;
        var marker = GWW.map.createMarker(photo, photo.pin_type == 'guess' ? '!' : '?');
        (photo.pin_type === 'guess' ? guesses : posts).push(marker);
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
      var markerParent = this.checked ? GWW.map.map : null;
      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(markerParent);
      }
    }
  };

  GWW.map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
  return publicMethods;
})();
