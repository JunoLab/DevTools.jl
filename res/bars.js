(function(){

  Bars = {};

  // Utils

  function callback(t, f) {
    if (!f) { f = t; t = 0; } // callback(f)
    return setTimeout(f, t);
  }

  function forEach(xs, f) {
    return Array.prototype.forEach.call(xs, f)
  }

  function toPercent(x) {
    return x*100 + "%";
  }

  // Adding bars

  var liveHandles = [];

  function set(cm, ls) {
    ls.forEach(function(l) {
      lh = cm.getLineHandle(l.line-1);
      if (!lh) { return; }
      lh.percent = toPercent(l.percent);
      liveHandles.push(lh);
    });
    cm.refresh();
  }

  Bars.set = set;

  // Rendering

  function hook(cm) {
    cm.on('renderLine', renderBar);
  }

  function renderBar(cm, line, dom) {
    if (line.percent) {
      div = document.createElement('div');
      div.classList.add('bar');
      div.style.width = line.percent;
      dom.appendChild(div);
    }
  }

  Bars.hook = hook;

  // Animation

  function allBars() {
    return document.querySelectorAll('.CodeMirror-code .bar');
  }

  function on() {
    forEach(allBars(), function(bar) {
      bar.classList.remove('animated');
      bar.classList.add('hidden');
    });
    callback(function() { // Allow DOM to update for 'hidden' class
      forEach(allBars(), function(bar) {
        bar.classList.add('animated');
        bar.classList.remove('hidden');
      });
    });
  }

  function off() {
    forEach(allBars(), function(bar) {
      bar.classList.add('animated');
      bar.classList.add('hidden');
    });
  }

  Bars.on = on;
  Bars.off = off;

})();
