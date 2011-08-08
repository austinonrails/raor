Ext.regModel('Event', {
  fields: ['created_at','creator','creator_id','description','end_date','id','is_checked_in?','name','start_date','updated_at']
});

Ext.regModel('Checkin', {
  fields: ['created_at','employ','employment','event_id','id','shoutout','updated_at','user','user_id']
});

var toolbar = new Ext.Toolbar({
  dock: 'top',
  xtype: 'toolbar',
  ui: 'light',
  title: 'AOR Check-in',
  items: []
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

var eventsList = new Ext.List({
  fullscreen:true,
  indexBar: true,
  itemTpl: '<h2>{name}</h2><p class="description">{description}</p>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        this.application.raor.removeAll(false);
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
  },
  loadingText: 'Loading Events...',
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

var checkinButton = new Ext.Button({
  text: 'Check-In',
  hidden: true
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
  items: [eventsList, eventPanel]
});

var application = new Ext.Application({
  launch: function() {
    this.raor = new Ext.ux.Raor();
  }
});
