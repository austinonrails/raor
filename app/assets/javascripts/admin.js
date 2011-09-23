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
      this.adminEventFormPanel.clearForm();
      this.adminCheckinStore.remove(this.adminCheckinStore.getRange());
      this.application.raor.setActiveItem(this.adminEventPanel);
    }
  },{
    xtype: 'button',
    text: 'Manage Events',
    scope: this,
    handler: function(btn) {
      this.backButton.show();
      this.application.raor.setActiveItem(this.adminEventsList);
    }
  },{
    xtype: 'button',
    text: 'Manage Users',
    scope: this,
    handler: function(btn) {
      this.backButton.show();
      this.application.raor.setActiveItem(this.usersPanel);
    }
  },{
    xtype: 'spacer'
  }]
});
