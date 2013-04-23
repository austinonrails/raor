//= require jquery
//= require jquery_ujs
//= require foundation
//= require jquery-ui
//= require underscore
//= require handlebars
//= require ember
//= require ember-data
//= require raor
//= require_self

$(document).foundation();
Raor = Ember.Application.create();

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
