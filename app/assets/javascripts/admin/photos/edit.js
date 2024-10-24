GWW.admin = {};
GWW.admin.photos = {};
GWW.admin.photos.edit = function () {
  "use strict";

  return {
    setUp: setUp
  };

  function setUp() {
    setUpCopyUsername();
    preventSubmitPartialUsernameForm();
  }

  function setUpCopyUsername() {
    var forms = $('#comments form');
    for (var i = 0; i < forms.length; i++) {
      var form = forms[i];
      if (/add_selected_answer/.test(form.action)) {
        $(form.commit).click(copyUsernameFor(form));
      }
    }
  }

  function copyUsernameFor(form) {
    return function () {
      form.username.value = $('#username')[0].value;
    };
  }

  function preventSubmitPartialUsernameForm() {
    $('#username_form').submit(function (event) {
      if (this.answer_text.value === '') {
        event.stopImmediatePropagation(); // Not necessary for functionality. Permits testing.
        return false;
      } else {
        return true;
      }
    });
  }

}();
