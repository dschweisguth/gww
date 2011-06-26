GWW.photos = {};
GWW.photos.map = (function () {
  var that = GWW.shared.createMap();

  var superSetUp = GWW.superior(that, 'setUp');
  that.setUp = function () {
    superSetUp('GWW.photos.map.mapsAPIIsLoadedCallback');
  };

  return that;
})();
