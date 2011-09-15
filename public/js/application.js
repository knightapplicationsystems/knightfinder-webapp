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
  
  //////////////// EDIT VENUE /////////////////
  
  $(".edit-deal-link").click(function(e) {
    e.preventDefault();
    $(this).closest("tr.deal-row").hide();
    $($(this).attr("href")).show();
  });
  
  
  
  
  $(".save-deal-btn").click(function(e) {
    e.preventDefault();
    var active = false;
    var row_id = $(this).attr('id').split("-")[1];
    var row_id_str = "#edit-deal-row-" + row_id;
    
    
    $(row_id_str + " input, " + row_id_str + " textarea").attr('disabled', true);
    var summary = escape($(row_id_str + " input[name='summary']").val());
    var expires = $(row_id_str + " input[name='expires']").val();
    var active  = $(row_id_str + " input[name='active']").is(':checked') ? true : false;
    var featured = false;
    var details = escape($(row_id_str + " textarea[name='details']").val());
    
    alert(summary);
    
    // Do AJAX Post
    var dataString = 'id='+ row_id + '&_method=put&summary=' + summary + '&expires=' + expires + '&active=' + active + '&details=' + details; 
    var url = $(row_id_str + " form").attr('action');
    
    expires_string = $.timeago(expires);
    
    //Update the View with the new Data
    $("#deal-row-" + row_id + " .deal-summary").text(unescape(summary));
    $("#deal-row-" + row_id + " .deal-expires time").text(expires_string);
    $("#deal-row-" + row_id + " .deal-expires time").attr('datetime', expires).attr('title', expires);
    $("#deal-row-" + row_id + " .deal-details").text(unescape(details));
    var img_active = active ? 'tick' : 'cross';
    var img_featured = featured ? 'tick' : 'cross';
    $("#deal-row-" + row_id + " .deal-active img").attr('src', "/images/" + img_active + ".png");
    $("#deal-row-" + row_id + " .deal-featured img").attr('src', "/images/" + img_featured + ".png");
    $("#deal-row-" + row_id + " .deal-edit a").hide();
    $("#deal-row-" + row_id + " .deal-edit").append("<em>Saving...</em>");
    
    $.post(url, dataString, function(data) {
      $("#deal-row-" + row_id + " .deal-edit a").show();
      $("#deal-row-" + row_id + " .deal-edit em").remove();
    })
    
    $(row_id_str).hide();
    $("#deal-row-" + row_id).show();
    $(row_id_str + " input, " + row_id_str + " textarea").attr('disabled', false);
    
  });
  
  
  
  //////////////// CHANGE ALL <time> ELEMENTS TO TIME AGO /////////////////
  
  jQuery.timeago.settings.allowFuture = true;
  $("time").timeago();
  
  
  
  ///////////////// Get Lat/Long on CREATE VENUE PAGE ///////////////////
  
  $("#get-ll").click(function(e) {
    //e.preventDefault();
    params = $("input[name=address1]").val() + ", " + $("input[name=address2]").val() + ", " + $("input[name=address3]").val() + ", " + $("input[name=city]").val() + ", " + $("input[name=postcode]").val();
    var dataString = 'address='+ escape(params);
    alert(dataString);
    $.get("/findlatlong", dataString, function(data) {
      alert(data);
    });
  });
});