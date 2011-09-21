Ext.regModel('Event', {
  fields: [
    {name: 'created_at', type: 'date'},
    {name: 'creator', type: 'auto'},
    {name: 'creator_id', type: 'auto'},
    {name: 'description', type: 'string'},
    {name: 'end_date', type: 'date'},
    {name: 'id', type: 'auto'},
    {name: 'is_checked_in?', type: 'boolean'},
    {name: 'name', type: 'string'},
    {name: 'start_date', type: 'date'},
    {name: 'updated_at', type: 'date'}],
  isCheckinTime: function(record) {
    current_date = new Date();
    return current_date < record.data.end_date && current_date > record.data.start_date
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
    {name: 'user_id', type: 'int'}]
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
              this.eventContainer.update(records[index].data);
              proxy = this.checkinStore.getProxy();
              proxy.url = "/events/" + records[index].data.id + "/checkins.json";
              this.checkinFormPanel.url = proxy.url;
              (!records[index].data['is_checked_in?'] && records[index].isCheckinTime(records[index])) ? this.checkinButton.show() : this.checkinButton.hide();
              this.eventPanel.doLayout();
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
          this.eventContainer.update(records[0].data);
          proxy = this.checkinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins";
          this.checkinFormPanel.url = proxy.url;
          (!records[0].data['is_checked_in?'] && records[0].isCheckinTime(records[0])) ? this.checkinButton.show() : this.checkinButton.hide();
          this.eventPanel.doLayout();
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
  cls: 'list',
  disableSelection: true,
  emptyText: 'There is no-one currently checked in.',
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
        this.checkinStore.add(checkin.data);
      } else {
        var record = this.checkinStore.findRecord("id", this.checkinFormPanel.record.data.id);
        this.checkinFormPanel.updateRecord(record);
      }
      this.checkinStore.sync();
      this.checkinButton.hide();
      this.application.raor.activatePrevCard();
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
  clearForm: function() {
    var checkin = Ext.ModelMgr.create({}, 'Checkin');
    this.load(checkin);
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

var eventPanel = new Ext.Container({
  items: [eventContainer, checkinButton, checkinList]
});