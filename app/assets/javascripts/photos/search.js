// TODO Dave add pages when scrolling backwards instead of loading all pages right away
GWW.photos = {};
GWW.photos.search = function () {
  "use strict";

  function setUp() {
    setUpAutocomplete();
    setUpFormSubmit();
    setUpClearForm();
    setUpToggleHelp();
    addPages();
  }

  function setUpAutocomplete() {
    $("#username").autocomplete({
      source: function (request, response) {
        var url = '/photos/autocomplete_usernames';
        if (request.term !== "") {
          url += '/term/' + escape(request.term);
        }
        var gameStatus = $('form select[name="game_status[]"]'); // TODO Dave refactor
        if (gameStatus.val() !== null && gameStatus.val() !== "") {
          url += "/game-status/" + gameStatus.val();
        }
        $.getJSON(
          url,
          {},
          function (data) {
            response($.map(data, function (item) {
              return {
                label: item.label,
                value: item.username
              }
            }));
          }
        );
      },
      minLength: 0,
      open: function () {
        $(this).autocomplete('widget').css('z-index', 100);
        return false;
      }
    });
    $("form img").click(function () {
      $("#username").autocomplete("search", "").focus();
      return false;
    });
  }

  function setUpFormSubmit() {
    $('form').submit(function (event) {
      event.preventDefault();
      var path = '/photos/search';
      var gameStatus = $(this).find('select[name="game_status[]"]');
      if (gameStatus.val() !== null && gameStatus.val() !== "") {
        path += "/game-status/" + gameStatus.val();
      }
      var postedBy = $(this).find('[name="username"]');
      if (postedBy.val() !== "") {
        path += "/posted-by/" + encodeURIComponent(postedBy.val());
      }
      var text = $(this).find('[name="text"]');
      if (text.val() !== "") {
        path += "/text/" + encodeURIComponent(text.val());
      }
      var sortedBy = $(this).find('[name="sorted_by"]');
      if (sortedBy.val() !== null && sortedBy.val() !== "") {
        path += "/sorted-by/" + sortedBy.val();
      }
      var direction = $(this).find('[name="direction"]');
      if (direction.val() !== null && direction.val() !== "") {
        path += "/direction/" + direction.val();
      }
      window.location = path;
    });
  }

  function setUpClearForm() {
    $('#clear').click(function (event) {
      $(this).closest('form').find('input[type="text"], select').val("");
      event.preventDefault();
      return false;
    });
  }

  function setUpToggleHelp() {
    $('#search-help-icon').click(function () {
      $('#search-help').toggle();
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
      // Don't scroll if we're on page 1 so we can still see the form
      if (nextPageToAdd > 2) {
        $(window).scrollTop($('#' + (nextPageToAdd - 1)).position().top);
      }
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

  var willScrollLater = false;

  function setUpFillWindowAfterScrolling() {
    // A single scrolling gesture may result in many scroll events.
    // So, when the user scrolls, react only every so often.
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
            willScrollLater = false;
          }
        }, 250);
      }
    });
  }

  function addPage(afterPageAdded, afterAllPagesAdded) {
    $.ajax({
      url: '/photos/search_data' + terms() + '/sorted-by/' + GWW.config.sortedBy + '/direction/' + GWW.config.direction + '/page/' + nextPageToAdd,
      success: function (data) {
        allPagesAdded = ! /\S/.test(data)
        if (allPagesAdded) {
          if (afterAllPagesAdded != null) {
            afterAllPagesAdded();
          }
        } else {
          $('#photos').append(data);
          nextPageToAdd++;
          if (afterPageAdded != null) {
            afterPageAdded();
          }
        }
      },
      complete: function () {
        willScrollLater = false;
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
    $('#photos > div').hover(setMetadataVisibility('visible'), setMetadataVisibility('hidden'));
  }

  function setMetadataVisibility(visibility) {
    return function () {
      $(this).find('.bg, p:not(.by), .game-status').css('visibility', visibility);
    };
  }

  // TODO Dave but we'd rather update the hash only when the first div in the page is at the top of the viewport
  function updateHash() {
    $('#photos > div:in-viewport[id]:first').each(function (unused, firstDivInPage) {
      // The hash and IDs are intentionally different so that the browser doesn't scroll when we update the hash
      location.hash = "#page=" + firstDivInPage.id;
    });
  }

  function setUpHashChange() {
    window.onhashchange = function () {
      // TODO Dave scroll the page if necessary
      // TODO Dave do nothing if we know it was us that changed the hash?
      var matches = location.hash.match(/^#page=(\d*[1-9]+\d*)$/);
      if (matches != null && matches.length > 0) {
        if (! allPagesAdded && nextPageToAdd <= matches[1]) {
          addPagesUpTo(matches[1]);
        }
      }
    };
  }

  return {
    setUp: setUp
  };

}();
$(GWW.photos.search.setUp);
