Ext.ux.Raor = Ext.extend(Ext.Panel, {
  constructor: function(config) {
    if(config == undefined) config = {};
    if(window.ADMIN && adminToolbar != undefined) {
      Ext.apply(config, {
        dockedItems: [toolbar, adminToolbar],
        items: [eventsList, eventPanel, checkinFormPanel, newEventFormPanel, usersPanel, userFormPanel]
      });
    }
    Ext.ux.Raor.superclass.constructor.call(this, config);
  },
  fullscreen: true,
  layout: 'card',
  loaded: false,

  dockedItems: [toolbar],
  items: [eventsList, eventPanel, checkinFormPanel],
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
