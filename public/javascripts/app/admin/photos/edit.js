(function () {
  Event.observe(window, 'load', function() {
    setUpCopyUsername();
    preventSubmitPartialUsernameForm();
  });

  var setUpCopyUsername = function () {
    var comments = $('comments');
    if (comments) {
      var forms = comments.select('form');
      for (var i = 0; i < forms.length; i++) {
        if (/add_selected_answer/.test(forms[i].readAttribute('action'))) {
          var comment_id = forms[i]['comment_id'].value;
          setUpCopyUsernameFor(comment_id);
        }
      }
    }
  }

  var setUpCopyUsernameFor = function (comment_id) {
    $('submit_' + comment_id).observe('click', function () {
      $('username_' + comment_id).value = $('person_username').value;
    });
  }

  var preventSubmitPartialUsernameForm = function () {
    var username_form = $('username_form');
    if (username_form) {
      username_form.observe('submit', function (event) {
        var form = event.element();
        if (form['answer_text'].value === '') {
          event.preventDefault();
          return false;
        } else {
          return true;
        }
      });
    }
  }

})();
