$(document).ready(function() {
  $("#information .box").each(function(index, element) {
    $(element).addClass("animated flipInY");
    $(element).removeClass("hidden");
  });
});
