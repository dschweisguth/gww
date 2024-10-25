// TODO Dave add pages when scrolling backwards instead of loading all pages right away
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
      source: (request, response) => $.getJSON(photosPersonAutocompletionsURI(request), {}, response),
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

  function photosPersonAutocompletionsURI(request) {
    let uri = '/photos/person_autocompletions';
    if (request.term) {
      uri += '/term/' + encodeURIComponent(request.term);
    }
    const gameStatus = $('form select[name="game_status[]"]').val();
    if (gameStatus) {
      uri += "/game-status/" + gameStatus;
    }
    return uri;
  }

  function setUpFormSubmit() {
    $('form').submit(function (event) {
      event.preventDefault();
      window.location = searchURI($(this));
    });
  }

  const appendTermParams = [
    ['[name="did"]',            val => val !== 'posted',                                            'did',          val => val],
    ['[name="done_by"]',        val => val,                                                         'done-by',      val => encodeURIComponent(val)],
    ['[name="text"]',           val => val,                                                         'text',         val => encodeURIComponent(val)],
    ['[name="game_status[]"]',  val => val,                                                         'game-status',  val => val], // Javascript automatically joins arrays with ,
    ['[name="from_date"]',      val => val,                                                         'from-date',    val => encodeURIComponent(escapeDate(val))],
    ['[name="to_date"]',        val => val,                                                         'to-date',      val => encodeURIComponent(escapeDate(val))],
    ['[name="sorted_by"]',      val => val !== (did === 'posted' ? 'last-updated' : 'date-taken'),  'sorted-by',    val => val],
    ['[name="direction"]',      val => val !== '-',                                                 'direction',    val => val]
  ];

  // This function and PhotosController#uri_params must agree on the canonical parameter order
  function searchURI(form) {
    return appendTermParams.reduce((path, params) => appendTerm(path, form, ...params), '/photos/search');
  }

  function appendTerm(path, form, field_selector, test, term_name, term_value) {
    const val = form.find(field_selector).val();
    if (test(val)) {
      path += "/" + term_name + "/" + term_value(val);
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
    moveDot(element, true);
  }

  function moveDotRight(element) {
    moveDot(element, false);
  }

  function moveDot(element, left) {
    $(element).animate({ left: (left ? '+=' : '-=') + distanceToMove }, 800,
      function () {
        $(element).css('z-index', (left ? '-100' : '100'));
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
    // noinspection CssInvalidPseudoSelector
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
