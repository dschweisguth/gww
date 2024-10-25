// Based on http://superdit.com/2011/02/25/flickr-style-loading-animation-using-jquery/
GWW.photos.loadingAnimation = function () {
  "use strict";

  let distanceToMove;
  let thread;

  function start() {
    const container = $('#loading-animation');
    container.toggle();
    const leftDot = container.find('> div:nth-child(1)');
    leftDot.css('left', ($(window).width() / 2) - leftDot.width());
    distanceToMove = leftDot.width() + 4;
    container.find('> div:nth-child(2)').css('left', leftDot.position().left + distanceToMove);
    thread = setInterval(play, 800);
  }

  function play() {
    const container = $('#loading-animation');
    const leftDot = container.find('> div:nth-child(1)');
    const rightDot = container.find('> div:nth-child(2)');
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

  function stop() {
    $('#loading-animation').toggle();
    clearInterval(thread);
  }

  return {
    start: start,
    stop: stop
  };

}();
