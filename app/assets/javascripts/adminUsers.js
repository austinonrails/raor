Ext.regModel('User', {
  fields: [
    {name: 'id', type: 'int'},
    {name: 'email', type: 'string'},
    {name: 'password', type: 'string'},
    {name: 'reset_password_sent_at', type: 'date'},
    {name: 'remember_created_at', type: 'date'},
    {name: 'sign_in_count', type: 'int'},
    {name: 'current_sign_in_at', type: 'date'},
    {name: 'last_sign_in_at', type: 'date'},
    {name: 'current_sign_in_ip', type: 'string'},
    {name: 'last_sign_in_ip', type: 'string'},
    {name: 'name', type: 'string'},
    {name: 'created_at', type: 'date'},
    {name: 'updated_at', type: 'date'},
    {name: 'roles', type: 'auto'}]
});

Ext.regModel('Role', {
  fields: [
    {name: 'role', type: 'string'}
  ]
});

var usersStore = new Ext.data.Store({
  model: 'User',
  storeId: 'id',
  proxy: {
    model: 'User',
    type: 'railsrest',
    format: 'json',
    url: '/admin_users',
    reader: {
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
    this.roleStore.loadRoles(window.ROLES);

    this.application.raor.setActiveItem(this.userFormPanel);

    this.roleList.selectRoles([]);
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
          this.userFormPanel.updateInfo(user);
          this.roleStore.loadRoles(window.ROLES);
          this.application.raor.setActiveItem(this.userFormPanel);
          this.roleList.selectRoles(user.data.roles);
        }
      }
    }
  },
  loadingText: 'Loading Users...',
  monitorOrientation: true,
  plugins: [{
    ptype: 'listpaging',
    autoPaging: true
  },{
    ptype: 'pullrefresh'
  }],
  singleSelect: true,
  store: usersStore
});

var usersPanel = new Ext.Panel({
  fullscreen: true,
  items: [newUserButton, usersList]
});

var roleStore = new Ext.data.Store({
  model: 'Role',
  loadRoles: function(roles) {
    this.each(function(record) {
      this.remove(record);
    }, this);
    Ext.each(roles, function(item, index, allItems) {
      this.add(Ext.ModelMgr.create({role: item}, 'Role'))
    }, this);
    roleList.refresh();
  }
});

var roleList = new Ext.List({
  itemTpl: '{role}',
  multiSelect: true,
  simpleSelect: true,
  store: roleStore,
  selectRoles: function(roles) {
    var sm = this.getSelectionModel();
    roleStore.each(function(record) {
      sm.deselect(record);
    }, this);
    var records = [];
    Ext.each(roles, function(item, index, allItems) {
      var record = roleStore.findRecord('role', item);
      if(record) records.push(record);
    }, this);
    sm.select(records);
  }
});

var userFormPanel = new Ext.form.FormPanel({
  url: '/admin_users.json',
  items: [{
    xtype: 'textfield',
    name: 'name',
    label: 'Name'
  },{
    xtype: 'emailfield',
    name: 'email',
    label: 'Email Address'
  },{
    xtype: 'passwordfield',
    name: 'password',
    label: 'Password'
  },{
    xtype: 'container',
    cls: 'x-field x-field-text x-label-align-left',
    items: [{
      xtype: 'container',
      cls: 'x-form-label',
      style: 'width: 30%;',
      html: '<span>Roles</span>'
    },{
      xtype: 'container',
      cls: 'x-form-field-container',
      items: [roleList]
    }]
  },{
    xtype: 'button',
    ui: 'confirm',
    text: 'Submit',
    scope: this,
    handler: function() {
      var formRecord = this.userFormPanel.getRecord();
      var roles = [];
      Ext.each(this.roleList.getSelectedRecords(), function(record) {
        roles.push(record.data.role);
      });

      if(formRecord == undefined || formRecord.data.id == undefined || formRecord.data.id == "") {
        var newRecord = Ext.ModelMgr.create({roles: roles}, 'User');
        this.userFormPanel.updateRecord(newRecord);
        this.usersStore.add(newRecord);
      } else {
        var storeRecord = usersStore.getById(formRecord.data.id);
        this.userFormPanel.updateRecord(storeRecord);
        storeRecord.data.roles = roles;
      }
      this.usersStore.sync();
      this.eventsStore.load();
      this.application.raor.clearPrevCard();
      this.application.raor.setActiveItem(this.usersPanel, this.eventsList);
    }
  },{
    xtype: 'container',
    id: 'info'
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
        Ext.Msg.alert("Failed","Failed to checkin due to error.");
      }
    }
  },
  scroll: 'vertical',
  updateInfo: function(user) {
    var info = Ext.ComponentMgr.get('info');
    var header = '<div class="x-field x-field-text x-label-align-left"><div class="x-form-label"><span>';
    var middle = '</span></div><div class="x-form-field-container">';
    var end = '</div></div>'
    var html = '';
    var fields = [
      {field: 'reset_password_sent_at', label: 'Reset Password Sent At'},
      {field: 'remember_created_at', label: 'Remember Created At'},
      {field: 'sign_in_count', label: 'Sign In Count'},
      {field: 'current_sign_in_at', label: 'Current Sign In At'},
      {field: 'current_sign_in_ip', label: 'Current Sign In IP'},
      {field: 'last_sign_in_ip', label: 'Last Sign In IP'},
      {field: 'created_at', label: 'Created At'},
      {field: 'updated_at', label: 'Updated At'}
    ];
    Ext.each(fields, function(item, index, allItems) {
      html += header;
      html += item['label']
      html += middle;
      var value = user.data[item['field']];
      if(value != undefined) {
        var date = new Date(value);
        if(date != 'Invalid Date') {
          value = date.toString();
        }
        html += value;
      }
      html += end;
    });
    info.html = html;
  }
});