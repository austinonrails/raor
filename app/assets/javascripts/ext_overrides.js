Ext.override(Ext.plugins.ListPagingPlugin, {
  onListUpdate : function() {
    if (this.list.store && this.list.store.data.length < (this.list.store.currentPage * this.list.store.pageSize)) {
      if (!this.rendered) {
        return false;
      } else if (!this.autoPaging) {
        this.el.removeCls('x-loading');
        this.el.remove();
      } else {
        this.loading = false;
      }
      return false;
    }

    if (!this.rendered) {
      this.render();
    }

    this.el.appendTo(this.list.getTargetEl());
    if (!this.autoPaging) {
      this.el.removeCls('x-loading');
    }
    this.loading = false;
  }
});

Ext.override(Ext.plugins.PullRefreshPlugin, {
  onBounceEnd: function(scroller, info) {
    if (info.axis === 'y') {
      if (this.isRefreshing) {
        this.isRefreshing = false;

        this.setViewState('loading');
        this.isLoading = true;

        if (this.refreshFn) {
          this.refreshFn.call(this, this.onLoadComplete, this);
        }
        else {
          this.list.getStore().load();
          this.list.getStore().currentPage = 1;
        }
      }
    }
  }
});

Ext.data.RailsRestProxy = Ext.extend(Ext.data.RestProxy, {
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
  }
});

Ext.data.ProxyMgr.registerType('railsrest', Ext.data.RailsRestProxy);

(function() {
  Ext.override(Ext.data.Store, {
    onProxyWrite: function(operation) {
      var data     = this.data,
        action   = operation.action,
        records  = operation.getRecords(),
        length   = records.length,
        callback = operation.callback,
        record, i;

      if (operation.wasSuccessful()) {
        if (action == 'create' || action == 'update') {
          for (i = 0; i < length; i++) {
            record = records[i];

            record.phantom = false;
            record.join(this);
            if(action == 'create') {
              var old = data.findBy(function(item) { return item.phantom == true});
              data.replace(old.internalId, record);
            } else {
              data.replace(record);
            }
          }
        }

        else if (action == 'destroy') {
          for (i = 0; i < length; i++) {
            record = records[i];

            record.unjoin(this);
            data.remove(record);
          }

          this.removed = [];
        }

        this.fireEvent('datachanged');
      }


      if (typeof callback == 'function') {
          callback.call(operation.scope || this, records, operation, operation.wasSuccessful());
      }
    }
  });
})();