(function () {
  'use strict';
  if (!window.MathJax || !MathJax.startup) return;

  MathJax.startup.promise.then(function () {
    var blocks = [];
    document.querySelectorAll('.prose mjx-container[display="true"]').forEach(function (math) {
      var block = document.createElement('div');
      block.className = 'equation-block';
      math.before(block);
      block.append(math);
      blocks.push(block);
    });

    function updateOverflow() {
      blocks.forEach(function (block) {
        if (block.scrollWidth > block.clientWidth + 1) {
          block.tabIndex = 0;
          block.setAttribute('role', 'region');
          block.setAttribute('aria-label', '数学公式，可左右滚动');
        } else {
          block.removeAttribute('tabindex');
          block.removeAttribute('role');
          block.removeAttribute('aria-label');
        }
      });
    }

    updateOverflow();
    if ('ResizeObserver' in window) {
      var observer = new ResizeObserver(updateOverflow);
      blocks.forEach(function (block) { observer.observe(block); });
    } else {
      window.addEventListener('resize', updateOverflow);
    }
    if (document.fonts) document.fonts.ready.then(updateOverflow);
  });
})();
