(function () {
  $(function() {
    setUpCopyUsername();
    preventSubmitPartialUsernameForm();
  });

  var setUpCopyUsername = function () {
    var forms = $('#comments form');
    for (var i = 0; i < forms.length; i++) {
      if (/add_selected_answer/.test(forms[i].action)) {
        var comment_id = forms[i]['comment_id'].value;
        setUpCopyUsernameFor(comment_id);
      }
    }
  };

  var setUpCopyUsernameFor = function (comment_id) {
    $('#submit_' + comment_id).click(function () {
      $('#username_' + comment_id)[0].value = $('#username')[0].value;
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
