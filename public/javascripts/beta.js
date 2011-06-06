function handle_modal_opening() {
	$('a#join').click(function() {
		$('#beta-modal').show();
	});
}

function handle_modal_closing() {
	$('#beta-modal .cover, #beta-modal a.close').click(function() {
		$('#beta-modal').hide();
		return false;
	});
}

var beta_form_validator;
function handle_form_validation() {
	// we have to remove the extra checkbox Rails inserts for the 0 value
	$('#beta-join-form input[name="user[tos_accepted]"][value="0"]').remove();
	var $beta_join_button = $('#beta-join-form input[type="submit"]');
	beta_form_validator = $('#beta-join-form').validate({
		rules: {
			'user[invitation_code]': {required:true,minlength:6,maxlength:6},
			'user[first_name]': 'required',
			'user[last_name]': 'required',
			'user[email]': {required:true,email:true},
			'user[password]': {required:true,minlength:6},
			'user[tos_accepted]': {required:true}
		},
		messages: {
			'user[invitation_code]':{required:'Required',minlength:'Codes are 6 characters long.',maxlength:'Codes are 6 characters long.'},
			'user[first_name]':'Required',
			'user[last_name]':'Required',
			'user[email]':{required:'Required'},
			'user[tos_accepted]': {required:'Must be accepted'}
		}
	});
}

function handle_form_placeholder_labels() {
	$('#beta-modal form input').focus(function() {
		var $input = $(this);
		$input.parents('form:eq(0)').find('li').removeClass('focused');
		$input.parent().addClass('focused');
	});
	$('#beta-modal form input').keyup(function() {
		var $input = $(this);
		if ($input.val() != '') {
			$input.parent().addClass('filled');
		} else {
			$input.parent().removeClass('filled');
		}
	});
}

$(document).ready(function(){
	handle_modal_opening();
	handle_modal_closing();
	handle_form_validation();
	handle_form_placeholder_labels();
});