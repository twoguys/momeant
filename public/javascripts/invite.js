function handle_invitation_form() {
	$('#invitation-instructions form')
		.bind('ajax:before', function() { $('#invitation-instructions').addClass('loading'); })
		.bind('ajax:complete', function() { $('#invitation-instructions').addClass('complete').removeClass('loading'); });
		
	var invite_form_validator = $('#invitation-instructions form').validate({
		rules: {
			'name': {required:true,minlength:1},
			'email': {required:true,email:true},
			'about': {required:true,minlength:20}
		},
		messages: {
			'name':'Required',
			'about':{required:'Required',minlength:'A bit more than that...'}
		}
	});
}

$(document).ready(function() {
	$("a.apply").fancybox({scrolling: 'no'});
	handle_invitation_form();
});