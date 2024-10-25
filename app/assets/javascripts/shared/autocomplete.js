GWW.shared.autocomplete = function (selector, requestToAutocompletionsURI) {
  $(selector).autocomplete({
    source: (request, response) => { $.getJSON(requestToAutocompletionsURI(request), {}, response) },
    minLength: 0,
    open: function () {
      $(this).autocomplete('widget').css('z-index', 100);
      return false;
    }
  });
};
