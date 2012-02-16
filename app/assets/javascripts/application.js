//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.mobile
//= require jquery.mobile.datebox
//= require jquery.mobile.pagination
//= require_tree

$.ajaxPrefilter( function(options, originalOptions, jqXHR) {
    if ( applicationCache &&
        applicationCache.status != applicationCache.UNCACHED &&
        applicationCache.status != applicationCache.OBSOLETE ) {
        // the important bit
        options.isLocal = true;
    }
});
