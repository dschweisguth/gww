// TODO Dave add pages when scrolling backwards instead of loading all pages right away
// TODO Dave scrolling fast or editing the hash sometimes results in weird bugs. I've seen
// - a page loaded twice
// - the page refuse to scroll down, but jump back up a page
GWW.photos = {};
GWW.photos.search = function () {

  function setUp() {
    setUpForm();
    addPages();
  }

  function setUpForm() {
    $('form').submit(function (event) {
      event.preventDefault();
      var path = '/photos/search';
      var gameStatus = $(this).find('[name="game_status[]"]'); // TODO Dave hyphens
      if (gameStatus.val() !== "") { // TODO Dave fix null game status
        path += "/game_status/" + gameStatus.val();
      }
      var postedBy = $(this).find('[name="username"]');
      if (postedBy.val() !== "") {
        path += "/posted_by/" + postedBy.val();
      }
      location = path;
    });
  }

  var nextPageToAdd = 1;
  var allPagesAdded = false;

  function addPages() {
    var matches = location.hash.match(/^#page=(\d*[1-9]+\d*)$/);
    if (matches != null && matches.length > 0) {
      addPagesUpTo(matches[1]);
    } else {
      addPagesToFillWindow();
    }
  }

  function addPagesUpTo(lastPage) {
    addPage(function () {
      $(window).scrollTop($('#' + (nextPageToAdd - 1)).position().top);
      if (nextPageToAdd <= lastPage) {
        addPagesUpTo(lastPage);
      } else {
        addPagesToFillWindow();
      }
    }, null);
  }

  // When the page loads the document and window height are equal.
  // Load content until the document is longer than the window.
  function addPagesToFillWindow() {
    if ($(document).height() <= $(window).height()) {
      if (! allPagesAdded) {
        addPage(addPagesToFillWindow, afterAddingPages);
      }
    } else {
      afterAddingPages();
      setUpFillWindowAfterScrolling();
      setUpHashChange();
    }
  }

  function setUpFillWindowAfterScrolling() {
    // A single scrolling gesture may result in many scroll events.
    // So, when the user scrolls, react only every so often.
    var willScrollLater = false;
    $(window).scroll(function () {
      if (! willScrollLater) {
        willScrollLater = true;
        setTimeout(function () {
          if ($(window).scrollTop() >= $(document).height() - $(window).height() - 488) { // 488 = the height of two rows, so we never see a partial row
            if (! allPagesAdded) {
              addPage(afterAddingPages, null);
            }
          } else {
            updateHash();
          }
          willScrollLater = false;
        }, 250);
      }
    });
  }

  function addPage(afterPageAdded, afterAllPagesAdded) {
    $.ajax({
      url: '/photos/search_data' + terms() + '/page/' + nextPageToAdd,
      success: function (data) {
        allPagesAdded = ! /\S/.test(data)
        if (allPagesAdded) {
          if (afterAllPagesAdded != null) {
            afterAllPagesAdded();
          }
        } else {
          $('body > div').append(data);
          nextPageToAdd++;
          if (afterPageAdded != null) {
            afterPageAdded();
          }
        }
      }
    });
  }

  function terms() {
    var names = [];
    var name;
    for (name in GWW.config.terms) {
      if (GWW.config.terms.hasOwnProperty(name)) {
        names.push(name);
      }
    }
    var terms = "";
    for (name in GWW.config.terms) {
      terms += '/' + name + '/' + GWW.config.terms[name];
    }
    return terms;
  }

  function afterAddingPages() {
    setUpMetadataVisibility();
    updateHash();
  }

  function setUpMetadataVisibility() {
    $('body > div > div').hover(setMetadataVisibility('visible'), setMetadataVisibility('hidden'));
  }

  function setMetadataVisibility(visibility) {
    return function () {
      $(this).find('.bg, p:first-child').css('visibility', visibility);
    };
  }

  // TODO Dave but we'd rather update the hash only when the first div in the page is at the top of the viewport
  function updateHash() {
    $('body > div > div:in-viewport[id]:first').each(function (unused, firstDivInPage) {
      // The hash and IDs are intentionally different so that the browser doesn't scroll when we update the hash
      location.hash = "#page=" + firstDivInPage.id;
    });
  }

  function setUpHashChange() {
    $(window).hashchange(function () {
      // TODO Dave scroll the page if necessary
      // TODO Dave do nothing if we know it was us that changed the hash?
      var matches = location.hash.match(/^#page=(\d*[1-9]+\d*)$/);
      if (matches != null && matches.length > 0) {
        if (! allPagesAdded && nextPageToAdd <= matches[1]) {
          addPagesUpTo(matches[1]);
        }
      }
    });
  }

  return {
    setUp: setUp
  };

}();
$(GWW.photos.search.setUp);
