Ext.regModel('User', {
  fields: ['id','email','password','reset_password_sent_at','remember_created_at','sign_in_count','current_sign_in_at','last_sign_in_at','current_sign_in_ip','last_sign_in_ip','name','created_at','updated_at','roles_mask']
});

var adminToolbar = new Ext.Toolbar({
  dock: 'bottom',
  ui: 'light',
  items: [{
    xtype: 'spacer'
  },{
    xtype: 'button',
    text: 'New Event',
    scope: this,
    handler: function(btn) {
      this.backButton.show();
      this.application.raor.setActiveItem(this.newEventFormPanel);
    }
  },{
    xtype: 'button',
    text: 'Admin Users',
    scope: this,
    handler: function(btn) {
      this.backButton.show();
      this.application.raor.setActiveItem(this.usersPanel);
    }
  },{
    xtype: 'spacer'
  }]
});

var newEventFormPanel = new Ext.form.FormPanel({
  url: '/events.json',
  items: [{
    xtype: 'textfield',
    name: 'event[name]',
    label: 'Name'
  },{
    xtype: 'textareafield',
    name: 'event[description]',
    label: 'Description'
  },{
    xtype: 'datetimepickerfield',
    name: 'event[start_date]',
    label: 'Start Date',
    picker: {
      showYears: true
    }
  },{
    xtype: 'datetimepickerfield',
    name: 'event[end_date]',
    label: 'End Date',
    picker: {
      showYears: true
    }
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      this.newEventFormPanel.submit({waitMsg: {message:'Creating New Event'}});
    }
  }],
  listeners: {
    scope: this,
    submit: {
      fn: function(form, result) {
        this.application.raor.activatePrevCard();
        this.eventsStore.load();
      }
    },
    exception: {
      fn: function(form, result) {
        Ext.MessageBox.alert("Failed","Failed to create new event.");
      }
    }
  }
});

var usersStore = new Ext.data.Store({
  model: 'User',
  storeId: 'id',
  proxy: {
    model: 'User',
    type: 'rest',
    format: 'json',
    url: '/admin_users',
    buildUrl: function(request) {
      var records = request.operation.records || [],
        record  = records[0],
        format  = this.format,
        url     = request.url || this.url;

      if (this.appendId && record && record.data.id) {
        if (!url.match(/\/$/)) {
          url += '/';
        }

        url += record.getId();
      }

      if (format) {
        if (!url.match(/\.$/)) {
            url += '.';
        }

        url += format;
      }

      request.url = url;

      return Ext.data.RestProxy.superclass.buildUrl.apply(this, arguments);
    },
    reader: {
      type: 'json',
      root: 'users'
    },
    writer: {
      type: 'json',
      root: 'users'
    }
  },
  autoLoad: true,
  listeners: {
    scope: this,
    load: {
      fn: function(store, records, successful) {
        this.usersList.refresh();
      }
    }
  }
});

var newUserButton = new Ext.Button({
  text: 'New User',
  scope: this,
  handler: function(btn) {
    var user = Ext.ModelMgr.create({id: undefined}, 'User');
    this.userFormPanel.load(user);
    this.application.raor.setActiveItem(this.userFormPanel);
  }
});

var usersList = new Ext.List({
  indexBar: true,
  itemTpl: '<h2>{name}</h2><p class="email">{email}</p>',
  listeners: {
    scope: this,
    selectionchange: {
      fn: function(selectionModel, records) {
        if(records.length > 0) {
          var user = Ext.ModelMgr.create(records[0].data, 'User');
          this.userFormPanel.load(user);
          this.application.raor.setActiveItem(this.userFormPanel);
        }
      }
    }
  },
  loadingText: 'Loading Users...',
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
  store: usersStore
});

var usersPanel = new Ext.Panel({
  fullscreen: true,
  items: [newUserButton, usersList]
});

var userFormPanel = new Ext.form.FormPanel({
  url: '/admin_users.json',
  items: [{
    xtype: 'textfield',
    name: 'name',
    label: 'Name'
  },{
    xtype: 'textfield',
    name: 'email',
    label: 'Email Address'
  },{
    xtype: 'passwordfield',
    name: 'password',
    label: 'Password'
  },{
    xtype: 'hiddenfield',
    name: 'roles_mask'
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      var formRecord = this.userFormPanel.getRecord();
      if(formRecord == undefined || formRecord.data.id == undefined) {
        var newRecord = Ext.ModelMgr.create({}, 'User');
        this.userFormPanel.updateRecord(newRecord);
        this.usersStore.add(newRecord);
      } else {
        var storeRecord = usersStore.getById(formRecord.data.id);
        this.userFormPanel.updateRecord(storeRecord);
      }
      this.usersStore.sync();
      this.eventsStore.load();
      //this.checkinStore.load();
      this.application.raor.clearPrevCard();
      this.application.raor.setActiveItem(this.usersPanel, this.eventsList);
    }
  }],
  listeners: {
    scope: this,
    submit: {
      fn: function(form, result) {
        this.application.raor.activatePrevCard();
        this.usersStore.load();
      }
    },
    exception: {
      fn: function(form, result) {
        Ext.MessageBox.alert("Failed","Failed to checkin due to error.");
      }
    }
  }
});