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
  
  //////////////// EDIT Deal /////////////////
  
  $(".edit-deal-link").live('click', function(e) {
    e.preventDefault();
    $(this).closest("tr.deal-row").hide();
    $($(this).attr("href")).show();
  });
  
  
  
  
  $(".save-deal-btn").live('click', function(e) {
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
  
  
  //////////////// Add Deal /////////////////////
  
  $("#add-deal-link").click(function() {
    $("#new-deal-row").show();
    $(this).hide();
    return false;
  });
  
  $("#new-deal-row form").submit(function(e) {
    e.preventDefault();
    var active = false;

    $("#new-deal-row input, #new-deal-row textarea").attr('disabled', true);
    
    var summary = escape($("#new-deal-row input[name='summary']").val());
    var expires = $("#new-deal-row input[name='expires']").val();
    var active  = $("#new-deal-row input[name='active']").is(':checked') ? true : false;
    var featured = false;
    var details = escape($("#new-deal-row textarea[name='details']").val());

    // Do AJAX Post
    var dataString = '&summary=' + summary + '&expires=' + expires + '&active=' + active + '&details=' + details; 
    var url = $("#new-deal-row form").attr('action');

    //Update the View with the new Data
    $("#add-deal-link").show();
    $("#add-deal-link-container").append(" <em>Saving...</em>");

    $.post(url, dataString, function(data) {
      $("#add-deal-link-container em").remove();
      $('#deals table > tbody:last').append(data);
      $("#new-deal-row").hide();
      $("#new-deal-row input, #new-deal-row textarea").attr('disabled', false);
      $("#new-deal-row input[name='expires'], #new-deal-row input[name='summary'], #new-deal-row textarea").val(""); 
    })
  });
  
  
  
  //////////////// CHANGE ALL <time> ELEMENTS TO TIME AGO /////////////////
  
  jQuery.timeago.settings.allowFuture = true;
  $("time").timeago();
  
  
  
  ///////////////// Get Lat/Long on CREATE VENUE PAGE ///////////////////
  
  $("#get-ll").click(function() {
    params = $("input[name=address1]").val()
    if ($("input[name=address2]").val() != "") {params = params + ", " + $("input[name=address2]").val();}
    if ($("input[name=address3]").val() != "") {params = params + ", " + $("input[name=address3]").val();}
    if ($("input[name=city]").val() != "") {params = params + ", " + $("input[name=city]").val();}
    if ($("input[name=postcode]").val() != "") {params = params + ", " + $("input[name=postcode]").val();}
    
    //alert("/findlatlong?address=" + escape(params));
    $.get("/findlatlong?address=" + escape(params), function(data) {
      a = data.split(",");
      $("input[name=latitude]").val(a[0]);
      $("input[name=longitude]").val(a[1]);
    });
  });
});