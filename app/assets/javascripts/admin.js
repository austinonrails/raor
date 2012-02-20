$(".page").live('pageinit', function(event) {
  $("#manage_users").live("change", function() {
    var link = $(this).find("option:selected").val();
    if(link != "Manage Users") {
      var manage_users = $("option[val='Manage Users']");
      $("option:selected").attr("selected", false);
      manage_users.attr("selected", true);
      manage_users.selectmenu("refresh");
      $.mobile.changePage(link);
    }
  });
});
