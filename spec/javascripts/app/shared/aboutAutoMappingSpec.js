//= require app/shared/aboutAutoMapping

describe('aboutAutoMapping', function () {
  describe('setUp', function () {
    it("sets up the link to open a window", function () {
      loadFixtures('aboutAutoMappingSpec.html');
      spyOn(window, 'open');
      GWW.shared.aboutAutoMapping.setUp();
      $('#about-auto-mapping').click();
      expect(window.open).toHaveBeenCalled();
    });
  });
});
