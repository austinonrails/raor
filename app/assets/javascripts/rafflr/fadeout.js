(function($) {
  $.raor.rafflr.prototype.transitions.fadeout = function(transition) {
    transition.duration(5000)
      .style("opacity", 0);
  }
}(jQuery));