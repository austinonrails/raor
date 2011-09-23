Ext.ux.Raor = Ext.extend(Ext.Panel, {
  constructor: function(config) {
    if(config == undefined) config = {};
    if(window.ADMIN && adminToolbar) {
      Ext.apply(config, {
        dockedItems: [toolbar, adminToolbar],
        items: [eventsList, eventPanel, eventCheckinContainer, checkinFormPanel, adminEventsList, adminEventPanel, usersPanel, userFormPanel]
      });
    }
    Ext.ux.Raor.superclass.constructor.call(this, config);
  },
  fullscreen: true,
  layout: 'card',
  loaded: false,
  monitorOrientation: true,

  dockedItems: [toolbar],
  items: [eventsList, eventPanel, eventCheckinContainer, checkinFormPanel],
  prevCard: [],
  activatePrevCard: function() {
    if(this.prevCard.length > 0) {
      var item = this.prevCard.pop()
      if(item === eventsList) backButton.hide();
      else backButton.show();
      this.superclass().setActiveItem.call(this, item);
    }
  },
  setPrevCard: function(card) {
    if(card == undefined) {
      this.prevCard.push(this.getActiveItem());
    } else {
      this.prevCard.push(card);
    }
  },
  setActiveItem: function (item, prevItem) {
    this.setPrevCard(prevItem == undefined ? this.getActiveItem() : prevItem);
    this.superclass().setActiveItem.call(this, item);
  },
  clearPrevCard: function() {
    this.prevCard = []
  },
  listeners: {
    afterrender: {
      fn: function() {
        if(window.application.loaded) this.setActiveItem(window.eventPanel);
      }
    },
    cardSwitch: {
      fn: function(container, newCard, oldCard, index, animated) {
        this.setCardHeight(newCard)
      }
    },
    orientationchange: {
      fn: function(container, orientation, width, height) {
        this.setCardHeight(this.getActiveItem());
      }
    }
  },
  setCardHeight: function(card) {
    var body = Ext.get(Ext.DomQuery.select("body")[0]);
    var height = Ext.Element.getViewportWidth() - toolbar.getHeight();
    if(adminToolbar) height -= adminToolbar.getHeight();
    body.setHeight(height);
    card.setHeight(height);
    
    if(card.xtype != "list") {
      var list_index = card.items.findIndex('xtype', 'list');
      if(list_index && list_index >= 0) {
        var height = card.getHeight();
        card.items.each(function(item, index, length) {
          if(index != list_index) {
            height -= item.getHeight();
          }
        });
        card.items.getAt(list_index).setHeight(height);
      }
    }
  }
});

var application = new Ext.Application({
  current_event: undefined,
  launch: function() {
    var params = this.getUrlVars();
    if(params["current_event"] != undefined) this.current_event = parseInt(params["current_event"]);
    this.raor = new Ext.ux.Raor();
  },
  getUrlVars: function() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = hash[1];
    }
    return vars;
  }  
});

function MilitaryTo12Hour(date) {
	function showTheHours(theHour) {
		return (theHour > 0 && theHour < 13) ? theHour : (theHour == 0 ? 12 : theHour-12);
	}

	function showZeroFilled(inValue) {
		return (inValue > 9) ? ":" + inValue : ":0" + inValue;
	}

	function showAmPm(date) {
		return date.getHours() < 12 ? " AM" : " PM";
	}

  return showTheHours(date.getHours()) + showZeroFilled(date.getMinutes()) + showZeroFilled(date.getSeconds()) + showAmPm(date);
}

function TimeRemaining(date) {
  var current_date = new Date();
  var time_left = date.getTime() - current_date.getTime();
  if(time_left <= 0) {
    return "<b>Already passed</b>";
  }
  var second = 1000;
  var minute = second * 60;
  var hour = minute * 60;
  var day = hour * 24;
  var days = Math.floor(time_left / day);
  var hours = Math.floor(time_left % day / hour);
  var minutes = Math.floor(time_left % day % hour / minute)
  var seconds = Math.floor(time_left % day % hour % minute / second);
  return days + " days " + hours + " hours " + minutes + " minutes " + seconds + " seconds";
}
