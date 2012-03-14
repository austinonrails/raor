(function($) {
  $.raor.rafflr.prototype.transitions.translate = function(transition) {
    var self = this;
    transition.duration(5000)
      .attr("transform", function(d, i) {
        return "translate(" + ((self.w / 2) - (d.width / 2)) + " " + ((self.h / 2) - (d.height / 2)) + ")";
      });
  }
}(jQuery));