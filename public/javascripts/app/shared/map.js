GWW = {};

GWW.map = function () {
  var loadMarkersFromPage = true;
  var jsonIncludedAllMarkers = false;
  var jsonBounds = null;
  var infoWindow = null;
  
  var that = {
    map: null,
    markers: [],

    registerOnLoad: function (callbackName) {
      $(function() {
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = 'http://maps.google.com/maps/api/js?v=3.4&sensor=false&callback=' + callbackName;
        document.body.appendChild(script);
      });
    },

    mapsAPIIsLoadedCallback: function () {
      that.map = new google.maps.Map($('#map_canvas')[0], {
        zoom: 13,
        center: new google.maps.LatLng(37.76, -122.435),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });

      new google.maps.Polyline({
        path: [
          new google.maps.LatLng(37.831853, -122.472668),
          new google.maps.LatLng(37.852543, -122.418787),
          new google.maps.LatLng(37.92944,  -122.432027),
          new google.maps.LatLng(37.885151, -122.376194),
          new google.maps.LatLng(37.811411, -122.345982),
          new google.maps.LatLng(37.708333, -122.281437),
          new google.maps.LatLng(37.708333, -122.557983),
          new google.maps.LatLng(37.815209, -122.584505),
          new google.maps.LatLng(37.815209, -122.529659)
        ],
        strokeColor: '#FF6600',
        strokeOpacity: 1.0,
        strokeWeight: 2
      }).setMap(that.map);

      google.maps.event.addListener(that.map, 'idle', loadMarkers);

      infoWindow = new google.maps.InfoWindow();

    }

  };

  var loadMarkers = function () {
    if (loadMarkersFromPage) {
      showMarkers(GWW.config);
      loadMarkersFromPage = false;
    } else if (! jsonIncludedAllMarkers || ! contains(jsonBounds, that.map.getBounds())) {
      var bounds = that.map.getBounds();
      var url = window.location + '_json?' +
        'sw=' + bounds.getSouthWest().lat() + ',' + bounds.getSouthWest().lng() + '&' +
        'ne=' + bounds.getNorthEast().lat() + ',' + bounds.getNorthEast().lng();
      $.getJSON(url, showMarkers);
    }
  };

  var contains = function(jsonBounds, mapBounds) {
    return(
      jsonBounds.min_lat <= mapBounds.getSouthWest().lat() && mapBounds.getNorthEast().lat() <= jsonBounds.max_lat &&
      jsonBounds.min_long <= mapBounds.getSouthWest().lng() && mapBounds.getNorthEast().lng() <= jsonBounds.max_long);
  };

  var showMarkers = function (photos) {
    jsonIncludedAllMarkers = ! photos.partial;
    jsonBounds = photos.bounds;
    $.each(that.markers, function (i, marker) { marker.setMap(null); });
    that.markers.length = 0;
    $.each(photos.photos, function (i, photo) {
      var marker = new google.maps.Marker({
        map: that.map,
        position: new google.maps.LatLng(photo.latitude, photo.longitude),
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + encodeURIComponent(photo.symbol) + '|' + photo.color + '|000000'
      });
      marker.symbol = photo.symbol; // Subclasses may use this to manage markers by photo type
      google.maps.event.addListener(marker, 'click', loadInfoWindow(photo, marker));
      that.markers.push(marker);
    })
  };

  var loadInfoWindow = function (photo, marker) {
    return function () {
      $.ajax({
        url: '/photos/' + photo.id + '/map_popup',
        success: openInfoWindow(marker)
      });
    };
  };

  var openInfoWindow = function (marker) {
    return function (html) {
      infoWindow.setContent(html);
      infoWindow.open(that.map, marker);
    }
  };

  return that;
};
