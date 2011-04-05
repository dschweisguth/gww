(function () {
  $(function() {
    setUpCopyUsername();
    preventSubmitPartialUsernameForm();
  });

  var setUpCopyUsername = function () {
    var forms = $('#comments form');
    for (var i = 0; i < forms.length; i++) {
      if (/add_selected_answer/.test(forms[i].action)) {
        setUpCopyUsernameFor(forms[i]);
      }
    }
  };

  var setUpCopyUsernameFor = function (form) {
    $(form['commit']).click(function () {
      form['username'].value = $('#username')[0].value;
    });
  };

  var preventSubmitPartialUsernameForm = function () {
    $('#username_form').submit(function (event) {
      if (this['answer_text'].value === '') {
        event.preventDefault();
        return false;
      } else {
        return true;
      }
    });
  }

})();
