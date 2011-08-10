Ext.regModel('Event', {
  fields: ['created_at','creator','creator_id','description','end_date','id','is_checked_in?','name','start_date','updated_at']
});

Ext.regModel('Checkin', {
  fields: ['created_at','employ','employment','event_id','id','shoutout','updated_at','user','user_id']
});


var backButton = new Ext.Button({
  xtype: 'button',
  text: 'Back',
  scope: this,
  handler: function(btn) {
    this.application.raor.activatePrevCard();
  }
});

var toolbar = new Ext.Toolbar({
  dock: 'top',
  xtype: 'toolbar',
  ui: 'light',
  title: 'AOR Check-in',
  items: [backButton]
});

var eventsStore = new Ext.data.Store({
  model: 'Event',
  proxy: {
    type: 'ajax',
    url: '/events/current.json',
    reader: {
      type: 'json',
      root: 'events'
    }
  },
  autoLoad: true,
  listeners: {
    scope: this,
    load: {
      fn: function(store, records, successful) {
        this.eventsList.refresh();
      }
    }
  }
});

//var paging = new Ext.plugins.ListPagingPlugin({
//  autoPaging: true
//});

var eventsList = new Ext.List({
  fullscreen:true,
  indexBar: true,
  itemTpl: '<h2>{name}</h2><p class="description">{description}</p>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        if(records.length > 0) {
          this.eventContainer.update(records[0].data);
          proxy = this.checkinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins.json";
          records[0].data['is_checked_in?'] ? this.checkinButton.hide() : this.checkinButton.show();
          this.checkinStore.load();
          this.application.raor.setPrevCard();
          this.application.raor.setActiveItem(this.eventPanel);
        }
      }
    }
  },
  loadingText: 'Loading Events...',
  monitorOrientation: true,
  //plugins: [paging],
  scroll: {
    listeners: {
      scrollend: {
        fn: function(scroller, offsets) {
          
        }
      }
    }
  },
  singleSelect: true,
  store: eventsStore
});

var eventContainer = new Ext.Container({
  tpl: '<h2>{name}</h2><p class="description">{description}</p><p>Created By: {creator.name}</p><p>Starts: {start_date}</p><p>Ends: {end_date}</p>'
});

var checkinStore = new Ext.data.Store({
  model: 'Checkin',
  proxy: {
    type: 'ajax',
    url: '/checkins.json',
    reader: {
      type: 'json',
      root: 'checkins'
    }
  },
  autoLoad: false,
  listeners: {
    scope: this,
    load: {
      fn: function(store, records, successful) {
        this.checkinList.refresh();
        //this.application.raor.doLayout();
      }
    }
  }
});

var checkinList = new Ext.List({
  indexBar: true,
  itemTpl: '<div class="summary"><p class="title"><span class="title{[values.employment ? " employment" : ""]}{[values.employ ? " employ" : ""]}">{user.name}</span></p><br/><p class="meta"><span class="shoutout">{shoutout}</span></p></div>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
      }
    }
  },
  loadingText: 'Loading Checkins...',
  monitorOrientation: true,
  scroll: {
    listeners: {
      scrollend: {
        fn: function(scroller, offsets) {

        }
      }
    }
  },
  singleSelect: true,
  store: checkinStore
});

var checkinFormPanel = new Ext.Panel({
  items: [{
    xtype: 'checkboxfield',
    label: 'Looking for Employment'
  },{
    xtype: 'checkboxfield',
    label: 'Looking to Employ'
  },{
    xtype: 'textareafield',
    label: 'Shout-out!'
  },{
    xtype: 'button',
    text: 'Submit',
    scope: this,
    handler: function() {
      Ext.Ajax.request({
        url: '/events/10/checkins.json',
        method: 'POST',
        params: {
          "checkin[employ]": this.checkinFormPanel.items.items[1].isChecked(),
          "checkin[employment]": this.checkinFormPanel.items.items[0].isChecked(),
          "checkin[shoutout]": this.checkinFormPanel.items.items[2].getValue()
        },
        scope: this,
        success: function(result, request) {
          this.checkinButton.hide();
          this.application.raor.setPrevCard(this.eventsList);
          this.application.raor.setActiveItem(this.eventPanel);
          this.checkinStore.load();
        },
        failure: function(result, request) {
          Ext.MessageBox.alert("Failed","Failed to checkin due to error.");
        }
      });
    }
  }]
});

var checkinButton = new Ext.Button({
  hidden: true,
  text: 'Check-In',
  scope: this,
  handler: function(btn) {
    this.application.raor.setPrevCard();
    this.application.raor.setActiveItem(this.checkinFormPanel);
  }
});

var eventPanel = new Ext.Panel({
  items: [eventContainer, checkinButton, checkinList]
});

Ext.ux.Raor = Ext.extend(Ext.Panel, {
//      constructor: function(config) {
//        Ext.Panel.superclass.constructor.call(this, config);
//      },
  fullscreen: true,
  layout: 'card',

  dockedItems: [toolbar],
  items: [eventsList, eventPanel, checkinFormPanel],
  prevCard: undefined,
  activatePrevCard: function() {
    if(this.prevCard != undefined) this.setActiveItem(this.prevCard);
  },
  setPrevCard: function(card) {
    if(card == undefined) {
      this.prevCard = this.getActiveItem();
    } else {
      this.prevCard = card;
    }
  }
});

var application = new Ext.Application({
  launch: function() {
    this.raor = new Ext.ux.Raor();
  }
});
