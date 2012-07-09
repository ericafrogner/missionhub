jQuery(document).ready(function(){
	// Show error upon loading
	$('.field_with_errors').each(function(){
		$(this).children().eq(0).blur();
	})
	
	// Disable enter key on fields
	$('select, input[type=text], input[type=password], input[type=email]').live('keypress', function(e){
	    if(e.which == 13) return false;
	});
	
	toggle_contacts_control();
	
})

function toggle_contacts_control(){
  if($('.id_checkbox').is(':checked'))
    $(".control_toggle").show();
  else
    $(".control_toggle").hide();
}