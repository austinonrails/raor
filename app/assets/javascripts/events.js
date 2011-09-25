Ext.regModel('Event', {
  fields: [
    {name: 'created_at', type: 'date'},
    {name: 'creator', type: 'auto'},
    {name: 'creator_id', type: 'auto'},
    {name: 'description', type: 'string'},
    {name: 'end_date', type: 'date'},
    {name: 'id', type: 'auto'},
    {name: 'is_checked_in', type: 'boolean'},
    {name: 'name', type: 'string'},
    {name: 'start_date', type: 'date'},
    {name: 'updated_at', type: 'date'}
  ],
  isCheckinTime: function(record) {
    current_date = new Date();
    return current_date < record.data.end_date && current_date > record.data.start_date;
  }
});

Ext.regModel('Checkin', {
  fields: [
    {name: 'created_at', type: 'date'},
    {name: 'employ', type: 'boolean', defaultValue: false},
    {name: 'employment', type: 'boolean', defaultValue: false},
    {name: 'event_id', type: 'int'},
    {name: 'hidden', type: 'boolean', defaultValue: false},
    {name: 'id', type: 'int'},
    {name: 'shoutout', type: 'string'},
    {name: 'updated_at', type: 'date'},
    {name: 'user', type: 'auto'},
    {name: 'user_id', type: 'int'}
  ]
});

var backButton = new Ext.Button({
  xtype: 'button',
  text: 'Back',
  hidden: true,
  scope: this,
  handler: function(btn) {
    this.application.raor.activatePrevCard();
  },
  ui: 'back'
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
    type: 'railsrest',
    format: 'json',
    url: '/events/current',
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
        if(this.application.raor == undefined || (!this.application.raor.loaded && this.application.raor.current_event)) {
          var current_event = undefined;
          if(this.application.raor == undefined) {
            var params = this.application.getUrlVars();
            if(params["current_event"]) current_event = parseInt(params["current_event"]);
          } else {
            current_event = this.application.raor.current_event;
          }
          if(current_event) {
            var index = store.findExact("id", current_event);
            if(index == -1) {
              store.nextPage();
            } else {
              this.eventsList.refresh();
              this.eventViewStore.remove(this.eventViewStore.getRange());
              this.eventViewStore.add(records[index]);
              proxy = this.checkinStore.getProxy();
              proxy.url = "/events/" + records[index].data.id + "/checkins.json";
              this.checkinFormPanel.url = proxy.url;
              this.checkinStore.load();
              this.checkinStore.currentPage = 1;
              this.backButton.show();
              this.application.loaded = true;
              if(this.application.raor != undefined) this.application.raor.setActiveItem(this.eventPanel);
            }
          }
        } else {
          this.eventsList.refresh();
        }
      }
    }
  }
});

var eventsList = new Ext.List({
  cls: 'list',
  fullscreen:true,
  indexBar: true,
  emptyText: 'There are no active events.',
  itemTpl: '<h2>{name}</h2><p class="description">{description}</p>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        if(records.length > 0) {
          this.eventContainer.record = records[0];
          this.eventViewStore.remove(this.eventViewStore.getRange());
          this.eventViewStore.add(records[0]);
          proxy = this.checkinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins";
          this.checkinFormPanel.url = proxy.url;
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

var eventViewStore = new Ext.data.Store({
  model: 'Event',
  proxy: {
    type: 'memory',
    reader: {
      type: 'json'
    }
  }
});

var eventContainer = new Ext.DataView({
  flex: 1,
  interval: undefined,
  record: undefined,
  itemSelector: "div.x-button",
  store: this.eventViewStore,
  tpl: new Ext.XTemplate('<tpl for=".">',
    '<div class="event"><div>',
      '<h2>{name}</h2><p class="description">{description}</p><p>Created By: {creator.name}</p>',
      '<p>Start Date: {[values.start_date.toLocaleDateString()]}</p>',
      '<p>Start Time: {[MilitaryTo12Hour(values.start_date)]}</p>',
      '<p>Time Until: {[TimeRemaining(values.start_date)]}</p>',
      '<p>End Date: {[values.end_date.toLocaleDateString()]}</p>',
      '<p>End Time: {[MilitaryTo12Hour(values.end_date)]}</p>',
    '</div></div>',
    '<tpl if="!is_checked_in && new Date() &lt; end_date && new Date() &gt; start_date">',
      '<div id="checkin" class="x-button x-button-normal"><span class="x-button-label">Checkin</span></div>',
    '</tpl>',
    '<div class="x-button x-button-normal"><span class="x-button-label">View Existing Checkins</span></div>',
  '</tpl>'),
  listeners: {
    scope: this,
    render: {
      fn: function() {
        if(this.interval) clearInterval();
        this.eventContainer.interval = setInterval("this.eventContainer.update(this.eventContainer.record.data)", 1000);
      }
    },
    itemtap: {
      fn: function(dataView, index, node, e) {
        var extnode = Ext.get(node);
        if(extnode.first()) extnode = extnode.first();
        switch(extnode.getHTML()) {
          case "Checkin":
            this.checkinFormPanel.clearForm();
            this.application.raor.setActiveItem(this.checkinFormPanel);
            break;
          case "View Existing Checkins":
            this.application.raor.setActiveItem(this.eventCheckinContainer);
            break;
          default:
            break;
        }
      }
    }
  },
  scroll: 'vertical'
});

var filterControls = new Ext.SegmentedButton({
  allowDepress: true,
  centered: true,
  items: [{
    xtype: 'spacer'
  },{
    text: 'LFW',
    handler: function(b, e) {
      if(b.el.hasCls(b.pressedCls)) {
        this.checkinStore.filters.add(new Ext.util.Filter({
          property: 'employ',
          value: true
        }));
        this.checkinStore.load();
      } else {
        this.checkinStore.clearFilter();
        this.checkinStore.load();
      }
    },
    scope: this,
    ui: 'round'
  },{
    text: 'LF1M',
    handler: function(b, e) {
      if(b.el.hasCls(b.pressedCls)) {
        this.checkinStore.filters.add(new Ext.util.Filter({
          property: 'employment',
          value: true
        }));
        this.checkinStore.load();
      } else {
        this.checkinStore.clearFilter();
        this.checkinStore.load();
      }
    },
    scope: this,
    ui: 'round'
  },{
    xtype: 'spacer'
  }]
});

var checkinStore = new Ext.data.Store({
  autoLoad: false,
  model: 'Checkin',
  proxy: {
    model: 'Checkin',
    type: 'railsrest',
    format: 'json',
    url: '/checkins',
    reader: {
      type: 'json',
      root: 'checkins'
    },
    writer: {
      type: 'json',
      root: 'checkins'
    }
  },
  remoteFilter: true,
  listeners: {
    scope: this,
    load: {
      fn: function(store, records, successful) {
        this.checkinList.refresh();
      }
    },
    datachanged: {
      fn: function(store, records, index) {
        this.eventsStore.load();
      }
    }
  }
});

var checkinList = new Ext.List({
  cls: 'list',
  disableSelection: true,
  emptyText: 'There is no-one currently checked in.',
  indexBar: true,
  itemTpl: '<div class="summary"><p class="title"><span class="title{[values.employment ? " employment" : ""]}{[values.employ ? " employ" : ""]}">{user.name}</span>' +
           '</p><br/><p class="meta"><span class="shoutout">{shoutout}</span></p></div>',
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
    name: 'employment',
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
    name: 'employ',
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
    name: 'shoutout',
    label: 'Shout-out!'
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      var checkin = Ext.ModelMgr.create({}, 'Checkin');
      if(this.checkinFormPanel.record.data.id == "") {
        this.checkinFormPanel.updateRecord(checkin);
        checkin.dirty = false;
        this.checkinStore.add(checkin.data);
      } else {
        var record = this.checkinStore.findRecord("id", this.checkinFormPanel.record.data.id);
        this.checkinFormPanel.updateRecord(record);
      }
      this.checkinStore.sync();
      this.application.raor.removeCard(this.eventPanel);
      this.application.raor.setActiveItem(this.eventCheckinContainer);
      this.application.raor.removeCard(this.checkinFormPanel);
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
  },
  scroll: 'vertical',
  clearForm: function() {
    var checkin = Ext.ModelMgr.create({}, 'Checkin');
    this.load(checkin);
  }
});

var eventCheckinButton = new Ext.Button({
  text: 'Checkin',
  scope: this,
  handler: function(btn) {
    this.application.raor.setActiveItem(this.eventCheckinContainer);
  }
});

var checkinButton = new Ext.Button({
  hidden: true,
  text: 'Check-In',
  scope: this,
  handler: function(btn) {
    this.checkinFormPanel.clearForm();
    this.application.raor.setActiveItem(this.checkinFormPanel);
  }
});

var eventCheckinContainer = new Ext.Container({
  items: [filterControls, checkinButton, checkinList]
});

var eventPanel = new Ext.Panel({
  layout: {
    type: 'vbox',
    align: 'stretch'
  },
  items: [eventContainer]
});