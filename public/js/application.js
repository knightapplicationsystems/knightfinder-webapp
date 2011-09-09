$(function() {
  
  //////////////// SIGN IN BOX ON HOME PAGE /////////////////
  
  $('#signin-link').hover(function(e) {
    e.preventDefault();
    $(this).addClass('hover');
    $('#signin-form').show();
  });
  
  //Prevent it dissapearing on mouseup
  $("#signin-form").mouseleave(function() {
    $(this).hide();
    $('#signin-link').removeClass('hover');
  });
  
  //////////////// END SIGN IN BOX ON HOME PAGE /////////////////
  
  
  
  
  
  
  
  
  
});