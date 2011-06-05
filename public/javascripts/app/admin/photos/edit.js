var GWW = {};
GWW.admin = {};
GWW.admin.photos = {};
GWW.admin.photos.Edit = (function () {

  var that = {
    setUp: function () {
      setUpCopyUsername();
      preventSubmitPartialUsernameForm();
    }
  };

  var setUpCopyUsername = function () {
    var forms = $('#comments form');
    for (var i = 0; i < forms.length; i++) {
      var form = forms[i];
      if (/add_selected_answer/.test(form.action)) {
        $(form['commit']).click(copyUsernameFor(form));
      }
    }
  };

  var copyUsernameFor = function (form) {
    return function () {
      form['username'].value = $('#username')[0].value;
    }
  };

  var preventSubmitPartialUsernameForm = function () {
    $('#username_form').submit(function (event) {
      return this['answer_text'].value !== '';
    });
  };

  return that;
})();
$(GWW.admin.photos.Edit.setUp);
