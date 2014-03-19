$(document).ready(function() {
  $(".feature").hover(function(e){
    $(this).children(".icon").transition({scale: 1.1}, 500, 'snap');
  }, function(e){ 
    $(this).children(".icon").transition({scale: 1.0}, 500, 'snap');
  });

  $(".pricing").hover(function(e){
    $(this).transition({ scale: 1.1 }, 500, 'snap');
  }, function(e){ 
    $(this).transition({ scale: 1.0 }, 500, 'snap');
  });
});
