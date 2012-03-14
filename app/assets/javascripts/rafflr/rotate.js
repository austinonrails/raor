(function($) {
  $.raor.rafflr.prototype.transitions.rotate = function(transition) {
    var r = 0;

    function rotate(d, i) {
      r += 180;
      var x = d.x + (d.bbox.width / 2);
      var y = (d.y + (d.bbox.height / 2));
      return "rotate(" + r + " " + x + " " + y + ") translate(" + d.x + " " + d.y + ")";
    }

    var transition2 = transition.transition();

    transition.delay(2500)
      .duration(2500)
      .attr("transform", rotate);

    transition2.duration(2500)
      .attr("transform", rotate);
  }
}(jQuery));