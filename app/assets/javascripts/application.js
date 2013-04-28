//= require jquery
//= require jquery_ujs
//= require foundation
//= //require jquery-ui
//= require underscore
//= require handlebars-1.0.0-rc.3
//= require ember-1.0.0-rc.3
//= require ember-data
//= require_self
//= require raor

$(document).foundation();
App = Ember.Application.create();

//$(document).on("pageinit", function() {
//  $.mobile.ajaxEnabled = true;
//});
//
//$("a#notice, a#alert").on("tap", function() {
//  $(this).fadeOut(1000, function() {
//    $(this).trigger("updatelayout");
//  });
//});
//
//$.ajaxPrefilter( function(options, originalOptions, jqXHR) {
//    if ( applicationCache &&
//        applicationCache.status != applicationCache.UNCACHED &&
//        applicationCache.status != applicationCache.OBSOLETE ) {
//        // the important bit
//        options.isLocal = true;
//    }
//});
