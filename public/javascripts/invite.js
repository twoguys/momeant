function handle_invitation_form() {
	$('#invitation-instructions form')
		.bind('ajax:loading', function() { $('#invitation-instructions').addClass('loading'); })
		.bind('ajax:complete', function() { $('#invitation-instructions').addClass('complete').removeClass('loading'); });
}

$(document).ready(function() {
	$("a.apply").fancybox({scrolling: 'no'});
	handle_invitation_form();
});