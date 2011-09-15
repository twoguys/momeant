function handle_nav_button_clicks() {
	$('#landing a.next').click(function() {
		var height = $(window).height();
		$('#letter').scrollTo('+=' + height + 'px', { duration: 200 });
		log('clicked');
	});
}

$(document).ready(function() {
	handle_nav_button_clicks();
});