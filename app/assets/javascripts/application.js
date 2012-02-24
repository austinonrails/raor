//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.mobile
//= require jquery.mobile.datebox
//= require jquery.mobile.pagination
//= require ajaxPoll
//= require_self

$(document).live("pageinit", function() {
  $.mobile.ajaxEnabled = true;
});

$("a#notice, a#alert").live("tap", function() {
  $(this).fadeOut(1000, function() {
    $(this).trigger("updatelayout");
  });
});

$.ajaxPrefilter( function(options, originalOptions, jqXHR) {
    if ( applicationCache &&
        applicationCache.status != applicationCache.UNCACHED &&
        applicationCache.status != applicationCache.OBSOLETE ) {
        // the important bit
        options.isLocal = true;
    }
});
