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