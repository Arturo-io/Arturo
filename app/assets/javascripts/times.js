$(function(){ 
  $("datetime").each(function(index, datetime) {
    var date      = $(datetime).html();
    var converted = moment(date).fromNow();
    $(datetime).html(converted);
  });
});
