//= require_self
//= require_tree ./rafflr

(function($) {
  $.widget( "raor.rafflr", {
    data: null,
    svg: null,
    topPadding: 20,
    textHeight: 30,
    textMargin: 5,
    transitionKeys: [],
    transitions: {},
    winners: 3,
    url: null,
    _create: function() {
      $.extend(true, this, this.options);
      $.Widget.prototype._create.apply(this, arguments);
    },
    _init: function() {
      var self = this;
      $.Widget.prototype._init.apply(self, arguments);

      for(var key in self.transitions){
        self.transitionKeys.push(key);
      }
    },
    _start: function(data, textStatus, jqXHR) {
      var self = this;
      self.data = $.map(data, function(value, indexOrKey) {
        return {id: value.user_id, name: value.user.name};
      });

      // Uncomment to add more names to the data
      self.data = self.data.concat([
        {id: 2, name: "Bob Jones"},
        {id: 3, name: "Nancy Reed"},
        {id: 4, name: "Larry David"},
        {id: 5, name: "George Foreman"},
        {id: 6, name: "Barry Lither"},
        {id: 7, name: "Cary Grant"},
        {id: 8, name: "Penelope Cruz"},
        {id: 9, name: "Steven Segal"},
        {id: 10, name: "Rasputin"}
      ]);

      var divElem = d3.select(".page");

      self.h = Math.round($(".page:visible").innerHeight() - $(".header").outerHeight(true) - $(".page:visible > .title").outerHeight(true) - $(".footer").outerHeight(true));
      self.w = $(".page:visible").innerWidth();

      // Create svg tag before div.footer
      self.svg = divElem.insert("svg", ".footer")
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .attr("height", this.h + "px")
        .attr("width", this.w + "px");

      // Force jQuery mobile to reset header and footer
      $("body").trigger("updatelayout");

      // Used to group the rect and text for each name for transforms
      var groups = self.svg.selectAll("g")
        .data(self.data, function(d) { return d.id; })
        .enter()
        .append("g");

      // Create text vertically centered
      var text = groups.append("text")
        .attr("class", "Label")
        .attr("dominant-baseline", "middle")
        .attr("x", 0)
        .attr("y", self.textHeight / 2)
        .attr("height", function(d, i) {
          return self.textHeight;
        });

      // Put text in tspan with slight horizontal padding
      text.append("tspan")
        .attr("x", self.textMargin)
        .text(function(d, i) {
          return d.name;
        });

      // Set bounding box property so we know what the text size is
      text.each(function(d, i) {
        d.bbox = this.getBBox();
      });

      // Have to create rects after text because text can't be measured until render
      // Rects need to be inserted before text so that text is on top of rect
      var rects = groups.insert("rect", "text")
        .attr("class", "name")
        .attr("x", function(d, i) {
          d.x = 0;
          return d.x;
        })
        .attr("y", function(d, i) {
          d.y = 0;
          return d.y;
        })
        .attr("width", function(d, i) {
          d.width = d.bbox.width + (self.textMargin * 2);
          return d.width;
        })
        .attr("height", function(d, i) {
          d.height = self.textHeight;
          return d.height;
        });

      // Now that we have valid text sizes, tile up the groups
      var row = 0;

      var filtered = groups.filter(function(d, i) {
        return i > 0;
      });
      var count = filtered[0].length;

      filtered.transition()
        .duration(5000)
        .attr("transform", function(d, i) {
          var prev = d3.select(groups[0][i]);
          var x = prev.data()[0].x;
          var y = prev.data()[0].y;
          var height = prev.data()[0].height;
          var width = prev.data()[0].width;
          d.x = x + width;
          d.y = y;
          if(d.x + d.width > self.w) {
            row += 1;
            d.x = 0;
            d.y = y + height;
          }
          return "translate(" + d.x + "," + d.y + ")";
        })
        .each("end", function(d, i) {
          count -= 1;
          if(count == 0) {
            $.proxy(self._bootLosers, self)();
          }
        });
    },
    _bootLosers: function() {
      var self = this;
      var selection = self.svg.selectAll("g");
      // Set bounding box property so we know what the text size is

      self.svg.selectAll("g").each(function(d, i) {
        d.bbox = this.getBBox();
      });

      self.data.splice(Math.floor(Math.random() * selection[0].length), 1);
      selection.data(self.data, function(d) { return d.id; })
        .exit()
        .transition()
        .call($.proxy(self._pickTransition, self))
        .remove()
        .each("end", function(d, i) {
          if(self.data.length > self.winners) {
            $.proxy(self._bootLosers, self)();
          } else {
            $.proxy(self._selectWinners, self)();
          }
        });
    },
    _selectWinners: function() {
      var self = this;
      var selection = self.svg.selectAll("g");

      var maxWidth = _.max($.map(selection.data(), function(value, indexOrKey) {
        return value.width;
      }));

      var maxHeight = _.max($.map(selection.data(), function(value, indexOrKey) {
        return value.height;
      }));

      var scale = 2;

      self.data = _.shuffle(self.data);
      selection.sort(function(a, b) {
          var aIndex = self.data.indexOf(a);
          var bIndex = self.data.indexOf(b);
          return aIndex >  bIndex ? -1 : (aIndex == bIndex ? 0 : 1);
        })
        .transition()
        .delay(3000)
        .duration(5000)
        .attr("transform", function(d, i) {
          var x = (self.w / 2) - (d.width * scale / 2);
          var yMargin = (self.h - (d.height * scale * selection[0].length)) / 2;
          var y = yMargin + (d.height * scale * i);
          return "translate(" + x + " " + y + ") scale(" + scale + ")"
        });
    },
    _pickTransition: function(transition) {
      var self = this;

      var pick = Math.floor(Math.random() * self.transitionKeys.length);
      self.transitions[self.transitionKeys[pick]].call(self, transition);
    },
    start: function() {
      var self = this;
      $.getJSON(self.url, $.proxy(self._start, self));
    }
  });
}(jQuery));