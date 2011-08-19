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
    this.application.raor.activatePrevCard();
  }
});

var toolbar = new Ext.Toolbar({
  dock: 'top',
  ui: 'light',
  title: 'AOR Check-in',
  items: [backButton]
});

var eventsStore = new Ext.data.Store({
  model: 'Event',
  clearOnPageLoad: false,
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

var eventsList = new Ext.List({
  fullscreen:true,
  indexBar: true,
  emptyText: 'There are no active events.',
  itemTpl: '<h2>{name}</h2><p class="description">{description}</p>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        if(records.length > 0) {
          this.eventContainer.update(records[0].data);
          proxy = this.checkinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins.json";
          this.checkinFormPanel.url = proxy.url;
          records[0].data['is_checked_in?'] ? this.checkinButton.hide() : this.checkinButton.show();
          this.checkinStore.load();
          this.checkinStore.currentPage = 1;
          this.backButton.show();
          this.application.raor.setActiveItem(this.eventPanel);
        }
      }
    }
  },
  loadingText: 'Loading Events...',
  monitorOrientation: true,
  plugins: [{
    ptype: 'listpaging',
    autoPaging: true
  },{
    ptype: 'pullrefresh'
  }],
  singleSelect: true,
  store: eventsStore
});

var eventContainer = new Ext.Container({
  tpl: '<h2>{name}</h2><p class="description">{description}</p><p>Created By: {creator.name}</p><p>Starts: {[new Date(values.start_date)]}</p><p>Ends: {[new Date(values.end_date)]}</p>'
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
      }
    }
  }
});

var checkinList = new Ext.List({
  indexBar: true,
  itemTpl: '<div class="summary"><p class="title"><span class="title{[values.employment ? " employment" : ""]}{[values.employ ? " employ" : ""]}">{user.name}</span></p><br/><p class="meta"><span class="shoutout">{shoutout}</span></p></div>',
  disableSelection: true,
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
      }
    }
  },
  loadingText: 'Loading Checkins...',
  monitorOrientation: true,
  plugins: [{
    ptype: 'listpaging',
    autoPaging: true
  },{
    ptype: 'pullrefresh'
  }],
  singleSelect: true,
  store: checkinStore
});

var checkinFormPanel = new Ext.form.FormPanel({
  url: '/events/nil/checkins.json',
  items: [{
    xtype: 'checkboxfield',
    name: 'checkin[employment]',
    label: 'Looking for Employment',
    value: true,
    listeners: {
      scope: this,
      check: {
        fn: function(checkbox) {
          Ext.each(this.checkinFormPanel.query('checkboxfield').remove(checkbox), function(item, index, allItems) {
            item.uncheck();
          })
        }
      }
    }
  },{
    xtype: 'checkboxfield',
    name: 'checkin[employ]',
    label: 'Looking to Employ',
    value: true,
    listeners: {
      scope: this,
      check: {
        fn: function(checkbox) {
          Ext.each(this.checkinFormPanel.query('checkboxfield').remove(checkbox), function(item, index, allItems) {
            item.uncheck();
          })
        }
      }
    }
  },{
    xtype: 'textareafield',
    name: 'checkin[shoutout]',
    label: 'Shout-out!'
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      this.checkinFormPanel.submit({waitMsg: {message:'Checking In'}});
    }
  }],
  listeners: {
    scope: this,
    submit: {
      fn: function(form, result) {
        this.checkinButton.hide();
        this.eventsStore.load();
        this.eventsStore.currentPage = 1;
        this.application.raor.setActiveItem(this.eventPanel, this.eventsList);
        this.checkinStore.load();
        this.checkinStore.currentPage = 1;
      }
    },
    exception: {
      fn: function(form, result) {
        Ext.Msg.alert("Failed","Failed to checkin due to error.");
      }
    }
  }  
});

var checkinButton = new Ext.Button({
  hidden: true,
  text: 'Check-In',
  scope: this,
  handler: function(btn) {
    this.application.raor.setActiveItem(this.checkinFormPanel);
  }
});

var eventPanel = new Ext.Panel({
  items: [eventContainer, checkinButton, checkinList]
});