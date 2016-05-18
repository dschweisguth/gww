GWW.shared.aboutAutoMapping = (function () {
  "use strict";

  return {
    setUp: function () {
      $('#about-auto-mapping').click(function() {
        window.open('/about-auto-mapping', 'Guess Where Watcher: About auto-mapping',
          'width=500,height=500,resizable=yes,scrollbars=yes,location=no,menubar=no,personalbar=no,toolbar=no,status=no');
        return false;
      });
    }
  };

}());
