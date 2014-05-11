//= require app/admin/photos/edit

describe('edit', function () {
  describe('setUp', function() {
    beforeEach(function () {
      loadFixtures('editSpec.html');
      GWW.admin.photos.edit.setUp();
    });

    describe("re copying the username from the username form to the guess/revelation forms", function() {
      it ("sets up copying", function () {
        var form = $('#comments form');
        $('#username')[0].value = 'the_username';
        form.submit(function () {
          return false;
        });
        $(form[0].commit).click();
        expect(form[0].username.value).toBe('the_username');
      });
    });

    describe("re submitting the username form", function() {
      it ("prevents submission if no answer text was entered", function() {
        var form = $('#username_form');
        spyOnEvent(form, 'submit');
        $(form[0].commit).click();
        expect('submit').not.toHaveBeenTriggeredOn(form);
      });

      it ("does not prevent submission if answer text was entered", function() {
        $('#answer_text')[0].value = 'an answer';
        var form = $('#username_form');
        form.submit(function () {
          return false;
        });
        spyOnEvent(form, 'submit');
        $(form[0].commit).click();
        expect('submit').toHaveBeenTriggeredOn(form);
      });

    });

  });
});
