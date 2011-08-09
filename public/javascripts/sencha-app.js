Ext.regModel('Event', {
  fields: ['created_at','creator','creator_id','description','end_date','id','is_checked_in?','name','start_date','updated_at']
});

Ext.regModel('Checkin', {
  fields: ['created_at','employ','employment','event_id','id','shoutout','updated_at','user','user_id']
});


var backButton = new Ext.Button({
  xtype: 'button',
  text: 'Back',
  hidden: true,
  scope: this,
  handler: function(btn) {
    if(this.eventPanel.isVisible()) {
      this.eventPanel.hide();
      this.eventsList.show();
      btn.hide();
    } else if(this.checkinFormPanel.isVisible()) {
      this.checkinFormPanel.hide();
      this.eventPanel.show();
    }
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
//          if(records.length > 0) {
//            this.event_id = records[0].data.id;
//            proxy = store.getProxy();
//            proxy.url = "/events/" + this.event_id + "/checkins.json";
//            store.load();
//          }
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
          this.backButton.show();
          this.eventsList.hide();
          this.eventContainer.update(records[0].data);
          proxy = this.checkinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins.json";
          if(!records[0].data['is_checked_in?']) this.checkinButton.show();
          this.checkinStore.load();
          this.eventPanel.show();
          this.eventPanel.doLayout();
          this.application.raor.doLayout();
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
        this.application.raor.doLayout();
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
  hidden: true,
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
          this.checkinFormPanel.hide();
          this.eventPanel.show();
          this.eventsStore.load();
        },
        failure: function(result, request) {
          Ext.MessageBox.alert("Failed","Failed to checkin due to error.");
        }
      });
    }
  }]
});

var checkinButton = new Ext.Button({
  text: 'Check-In',
  hidden: true,
  scope: this,
  handler: function(btn) {
    this.checkinFormPanel.show();
    this.eventPanel.hide();
    this.application.raor.doLayout();
  }
});

var eventPanel = new Ext.Panel({
  hidden: true,
  items: [eventContainer, checkinButton, checkinList]
});

Ext.ux.Raor = Ext.extend(Ext.Panel, {
//      constructor: function(config) {
//        Ext.Panel.superclass.constructor.call(this, config);
//      },
  fullscreen: true,

  dockedItems: [toolbar],
  items: [eventsList, eventPanel, checkinFormPanel]
});

var application = new Ext.Application({
  launch: function() {
    this.raor = new Ext.ux.Raor();
  }
});
