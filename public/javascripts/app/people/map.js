GWW.personMap = (function () {
  var guesses = [];
  var posts = [];

  var publicMethods = {

    registerOnLoad: function () {
      GWW.map.registerOnLoad('GWW.personMap.mapsAPIIsLoadedCallback');
    },

    mapsAPIIsLoadedCallback: function () {
      GWW.map.mapsAPIIsLoadedCallback();

      var photos = GWW.config;
      for (var i = 0; i < photos.length; i++) {
        var photo = photos[i].photo;
        var marker = GWW.map.createMarker(photo, '+', loadInfoWindow);
        (photo.pin_type === 'guess' ? guesses : posts).push(marker);
      }

      addToggleHandler('guesses', guesses);
      addToggleHandler('posts', posts);

    }

  };

  var loadInfoWindow = function (photo, marker) {
    return function () {
      var path = photo.pin_type == 'guess'
        ? window.location + '/' + photo.id + '/guess'
        : '/photos/' + photo.id + '/map_post';
      new Ajax.Request(path, {
        method: 'get',
        requestHeaders: { Accept: 'application/json' },
        onSuccess: GWW.map.openInfoWindow(marker)
      });
    };
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

  return publicMethods;
})();
GWW.personMap.registerOnLoad();
