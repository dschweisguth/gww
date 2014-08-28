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
    $("#done_by").autocomplete({
      source: function (request, response) {
        var url = '/photos/autocomplete_usernames';
        if (request.term !== "") {
          url += '/term/' + escape(request.term);
        }
        var gameStatus = $('form select[name="game_status[]"]');
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
              };
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
      $("#done_by").autocomplete("search", "").focus();
      return false;
    });
  }

  function setUpFormSubmit() {
    $('form').submit(function (event) {
      event.preventDefault();
      window.location = searchURI($(this));
    });
  }

  // This function and PhotosController#uri_params must agree on the canonical parameter order
  function searchURI(form) {
    var path = "/photos/search";
    var did = form.find('select[name="did"]').val();
    if (did !== 'posted') {
      path += "/did/" + did;
    }
    var doneBy = form.find('[name="done_by"]');
    if (doneBy.val() !== "") {
      path += "/done-by/" + encodeURIComponent(doneBy.val());
    }
    var text = form.find('[name="text"]');
    if (text.val() !== "") {
      path += "/text/" + encodeURIComponent(text.val());
    }
    var gameStatus = form.find('select[name="game_status[]"]');
    if (gameStatus.val() !== null && gameStatus.val() !== "") {
      path += "/game-status/" + gameStatus.val(); // Javascript automatically joins arrays with ,
    }
    var from_date = form.find('[name="from_date"]');
    if (from_date.val() !== "") {
      path += "/from-date/" + encodeURIComponent(escapeDate(from_date.val()));
    }
    var to_date = form.find('[name="to_date"]');
    if (to_date.val() !== "") {
      path += "/to-date/" + encodeURIComponent(escapeDate(to_date.val()));
    }
    var sortedBy = form.find('[name="sorted_by"]').val();
    if (sortedBy !== (did == 'posted' ? 'last-updated' : 'date-taken')) {
      path += "/sorted-by/" + sortedBy;
    }
    var direction = form.find('[name="direction"]').val();
    if (direction !== '-') {
      path += "/direction/" + direction;
    }
    return path;
  }

  // Replaces / with - to make dates URL-safe
  function escapeDate(date) {
    return date.replace(/\//g, '-');
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
    if (matches !== null && matches.length > 0) {
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
    startLoadingAnimation();
    $.ajax({
      url: searchDataURI(),
      success: function (data) {
        allPagesAdded = ! /\S/.test(data);
        if (allPagesAdded) {
          if (afterAllPagesAdded !== null) {
            afterAllPagesAdded();
          }
        } else {
          $('#photos').append(data);
          nextPageToAdd++;
          if (afterPageAdded !== null) {
            afterPageAdded();
          }
        }
      },
      complete: function () {
        willScrollLater = false;
        stopLoadingAnimation();
      }
    });
  }

  // Loading animation based on http://superdit.com/2011/02/25/flickr-style-loading-animation-using-jquery/

  var distanceToMove;
  var loadingAnimationThread;

  function startLoadingAnimation() {
    var container = $('#loading-animation');
    container.toggle();
    var leftDot = container.find('> div:nth-child(1)');
    leftDot.css('left', ($(window).width() / 2) - leftDot.width());
    distanceToMove = leftDot.width() + 4;
    container.find('> div:nth-child(2)').css('left', leftDot.position().left + distanceToMove);
    loadingAnimationThread = setInterval(playLoadingAnimation, 800);
  }

  function playLoadingAnimation() {
    var container = $('#loading-animation');
    var leftDot = container.find('> div:nth-child(1)');
    var rightDot = container.find('> div:nth-child(2)');
    moveDotLeft(leftDot);
    moveDotRight(leftDot);
    moveDotRight(rightDot);
    moveDotLeft(rightDot);
  }

  function moveDotLeft(element) {
    $(element).animate({ left: '+=' + distanceToMove }, 800,
      function () {
        $(element).css('z-index', '-100');
      }
    );
  }

  function moveDotRight(element) {
    $(element).animate({ left: '-=' + distanceToMove }, 800,
      function () {
        $(element).css('z-index', '100');
      }
    );
  }

  function stopLoadingAnimation() {
    $('#loading-animation').toggle();
    clearInterval(loadingAnimationThread);
  }

  function searchDataURI() {
    var match = /\/\/[^/]+\/photos\/search([^?#]*)/.exec(window.location);
    return '/photos/search_data' + match[1] + '/page/' + nextPageToAdd;
  }

  function afterAddingPages() {
    setUpMetadataVisibility();
    updateHash();
  }

  function setUpMetadataVisibility() {
    $('#photos > div.image').hover(setMetadataVisibility('visible'), setMetadataVisibility('hidden'));
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
      if (matches !== null && matches.length > 0) {
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
