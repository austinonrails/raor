Ext.ux.Raor = Ext.extend(Ext.Panel, {
  constructor: function(config) {
    if(config == undefined) config = {};
    if(window.ADMIN && adminToolbar != undefined) {
      Ext.apply(config, {dockedItems: [toolbar, adminToolbar]});
    } else {
      Ext.apply(config, {dockedItems: [toolbar]});
    }
    Ext.ux.Raor.superclass.constructor.call(this, config);
  },
  fullscreen: true,
  layout: 'card',

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
  }
});

var application = new Ext.Application({
  launch: function() {
    this.raor = new Ext.ux.Raor();
  }
});
