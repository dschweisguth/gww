describe('edit', function () {
  it ("copies the username", function () {
    loadFixtures('editSpec.html');
    GWW.admin.photos.Edit.setUp();
    var form = $('#comments form').first();
    form.submit(function () {
      return false;
    });
    $(form[0].commit).click();
    expect(form[0].username.value).toBe('the_username');
  });
});
