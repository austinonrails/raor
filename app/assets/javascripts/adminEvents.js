var adminEventFormPanel = new Ext.form.FormPanel({
  items: [{
    xtype: 'textfield',
    name: 'name',
    label: 'Name'
  },{
    xtype: 'textareafield',
    name: 'description',
    label: 'Description'
  },{
    xtype: 'datetimepickerfield',
    name: 'start_date',
    label: 'Start Date',
    display_format: 'm/d/Y h:i a',
    picker: {
      showYears: true
    }
  },{
    xtype: 'datetimepickerfield',
    name: 'end_date',
    label: 'End Date',
    display_format: 'm/d/Y h:i a',
    picker: {
      showYears: true
    }
  },{
    xtype: 'hiddenfield',
    name: 'id'
  },{
    xtype: 'button',
    text: 'Manage Checkins',
    scope: this,
    handler: function() {
      this.application.raor.setActiveItem(adminCheckinList);
    }
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      var event = Ext.ModelMgr.create({}, 'Event');
      if(this.adminEventFormPanel.record.data.id == "") {
        this.adminEventFormPanel.updateRecord(event);
        var errors = event.validate();
        var error_message = '';
        errors.each(function(item, index, length) {
          error_message += '<br/>' + item['field'] + ' ' + item['message'];
        });
        if(!errors.isValid()) {
          Ext.Msg.alert('Error', error_message);
          return false;
        }
        event.dirty = false;
        this.adminEventsStore.add(event.data);
      } else {
        var record = this.adminEventsStore.findRecord("id", this.adminEventFormPanel.record.data.id);
        var errors = record.validate();
        var error_message = '';
        errors.each(function(item, index, length) {
          error_message += '<br/>' + item['field'] + ' ' + item['message'];
        });
        if(!errors.isValid()) {
          Ext.Msg.alert('Error', error_message);
          return false;
        }
        this.adminEventFormPanel.updateRecord(record);
      }
      this.adminEventsStore.sync();
      this.application.raor.activatePrevCard();
    }
  }],
  listeners: {
    scope: this,
    exception: {
      fn: function(form, result) {
        Ext.Msg.alert("Failed","Failed to create new event.");
      }
    }
  },
  flex: 1,
  scroll: {
    constrain: 'parent',
    direciton: 'vertical'
  },
  clearForm: function() {
    var event = Ext.ModelMgr.create({}, 'Event');
    this.load(event);
    this.items.each(function(item, index, length) {
      if(item.xtype == "datetimepickerfield") {
        item.setValue(null);
      }
    });
  },
  loadFormFromRecord: function(rec) {
    var event = Ext.ModelMgr.create({
      'id': rec.data.id,
      'name': rec.data.name,
      'description': rec.data.description,
      'start_date': rec.data.start_date,
      'end_date': rec.data.end_date
    }, 'Event');
    this.load(event);
  }
});

var adminEventsStore = new Ext.data.Store({
  model: 'Event',
  clearOnPageLoad: false,
  proxy: {
    type: 'railsrest',
    format: 'json',
    url: '/events',
    reader: {
      type: 'json',
      root: 'events'
    },
    writer: {
      type: 'json',
      root: 'events'
    },
    listeners: {
      scope: this,
      exception: {
        fn: function(proxy, response, operation) {
          this.adminEventsStore.remove(this.adminEventsStore.last());
          Ext.Msg.alert("Failed","Failed to create event.");
        }
      }
    }
  },
  autoLoad: true,
  listeners: {
    scope: this,
    datachanged: {
      fn: function(store) {
        if(store.getById == undefined || store.getById("") == undefined) {
          this.adminEventsList.refresh();
          if(this.application.raor) this.eventsStore.load();
        }
      }
    }
  }
});

var adminEventsList = new Ext.List({
  cls: 'list',
  fullscreen:true,
  indexBar: true,
  emptyText: 'There are no active events.',
  itemTpl: '<h2 ref="{id}">{name}</h2><p class="description">{description}</p><button class="deleteEvent">Delete</button>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        if(records.length > 0) {
          this.adminEventFormPanel.loadFormFromRecord(records[0]);
          proxy = this.adminCheckinStore.getProxy();
          proxy.url = "/events/" + records[0].data.id + "/checkins";
          this.adminCheckinStore.load();
          this.adminCheckinStore.currentPage = 1;
          this.application.raor.setActiveItem(this.adminEventPanel);
        }
      }
    },
    update: {
      fn: function(dataView) {
        var deletes = Ext.DomQuery.select("button.deleteEvent");
        Ext.each(deletes, function(item, index, allItems) {
          var elem = Ext.get(item);
          elem.removeAllListeners();
          elem.addListener("tap", function(evt, el, o) {
            var id = Ext.get(Ext.get(el).prev("h2")).getAttribute('ref');
            var index = this.adminEventsStore.findExact("id", parseInt(id));
            this.adminEventsStore.removeAt(index);
            this.adminEventsStore.sync();
            this.adminEventFormPanel.clearForm();
            this.eventContainer.update(Ext.ModelMgr.create({},'Event'));
            this.checkinFormPanel.clearForm();
            this.eventsStore.load();
            this.checkinStore.remove(this.checkinStore.getRange());
            this.application.raor.removeCard(this.eventPanel);
            this.application.raor.removeCard(this.checkinFormPanel);
            this.application.raor.removeCard(this.checkinList);
          }, this, {
            stopEvent: true
          });
        }, this);
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
  store: adminEventsStore
});

var adminEventContainer = new Ext.Container({
  tpl: '<h2>{name}</h2><p class="description">{description}</p><p>Created By: {creator.name}</p><p>Starts: {[values.start_date]}</p><p>Ends: {[values.end_date)]}</p>'
});

var adminCheckinStore = new Ext.data.Store({
  model: 'Checkin',
  proxy: {
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
    },
    listeners: {
      scope: this,
      exception: {
        fn: function(proxy, response, operation) {
          this.adminCheckinStore.remove(this.adminCheckinStore.last());
          Ext.Msg.alert("Failed","Failed to hide or delete checkin.");
        }
      }
    }
  },
  autoLoad: false,
  listeners: {
    scope: this,
    load: {
      fn: function(store, records, successful) {
        this.adminCheckinList.refresh();
      }
    },
    datachanged: {
      fn: function(store) {
        if(this.checkinStore.proxy.url != '/checkins') this.checkinStore.load();
        this.eventsStore.load();
      }
    }
  }
});

var adminCheckinList = new Ext.List({
  cls: 'list',
  indexBar: true,
  itemTpl: '<div class="summary" ref="{[values.id]}"><p class="title"><span class="title{[values.employment ? " employment" : ""]}{[values.employ ? " employ" : ""]}">{user.name}</span></p>' +
           '<br/><p class="meta"><span class="shoutout">{shoutout}</span></p><button class="hideCheckin{[values.hidden ? " hidden" : ""]}">{[values.hidden ? "Unhide" : "Hide"]}</button>' +
           '<button class="deleteCheckin">Delete</button></div>',
  disableSelection: true,
  emptyText: 'There is no-one currently checked in.',
  fullscreen: true,
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
      }
    },
    update: {
      fn: function(dataView) {
        var hides = Ext.DomQuery.select(".hideCheckin");
        Ext.each(hides, function(item, index, allItems) {
          var elem = Ext.get(item);
          elem.removeAllListeners();
          elem.addListener("click", function(evt, el, o) {
            var element = Ext.get(el);
            var id = Ext.get(element.findParent(".summary")).getAttribute('ref');
            var record = adminCheckinStore.findRecord("id", parseInt(id));
            record.set('hidden', !element.hasCls("hidden"));
            this.adminCheckinStore.sync();
            this.checkinStore.load();
          }, this);
        }, this);

        var deletes = Ext.DomQuery.select("button.deleteCheckin");
        Ext.each(deletes, function(item, index, allItems) {
          var elem = Ext.get(item);
          elem.removeAllListeners();
          elem.addListener("click", function(evt, el, o) {
            var id = Ext.get(Ext.get(el).findParent(".summary")).getAttribute('ref');
            var index = adminCheckinStore.findExact("id", parseInt(id));
            this.adminCheckinStore.removeAt(index);
            this.adminCheckinStore.sync();
            this.application.raor.removeCard(this.eventPanel);
          }, this);
        }, this);
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
  store: adminCheckinStore,
  ui: 'action'
});

var adminEventPanel = new Ext.Container({
  layout: {
    type: 'vbox',
    align: 'stretch'
  },
  items: [adminEventFormPanel]
});