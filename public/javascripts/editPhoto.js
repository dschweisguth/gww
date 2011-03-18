(function () {
  function setUpCopyUsername() {
    var comments = $('comments');
    if (comments) {
      var forms = comments.select('form');
      for (var i = 0; i < forms.length; i++) {
        if (/add_answer/.test(forms[i].readAttribute('action'))) {
          var comment_id = forms[i]['comment_id'].value;
          (function (comment_id) {
            $('submit_' + comment_id).observe('click', function () {
              $('username_' + comment_id).value = $('person_username').value;
            });
          })(comment_id);
        }
      }
    }
  }

  function preventSubmitUsernameForm() {
    var username_form = $('username_form');
    if (username_form) {
      username_form.observe('submit', function (event) {
        event.preventDefault();
        return false;
      });
    }
  }

  Event.observe(window, 'load', function() {
    setUpCopyUsername();
    preventSubmitUsernameForm();
  });

})();
