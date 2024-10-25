GWW.shared.loadGoogleMaps = function (callbackName) {
  "use strict";

  const script = document.createElement('script');
  script.async = true;
  script.type = 'text/javascript';
  script.src = `https://maps.googleapis.com/maps/api/js?v=3&loading=async&libraries=marker&key=${GWW.config.api_key}&callback=${callbackName}`;
  document.body.appendChild(script);
}
