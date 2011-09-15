function handle_nav_button_clicks() {
	$('#landing a.next').click(function() {
		var height = $(window).height();
		$('#letter').scrollTo('+=' + height + 'px', { duration: 500 });
	});
	$("#landing a.top-link").click(function() {
		$('#letter').scrollTo(0, { duration: 500 });
	});
}

$(document).ready(function() {
	handle_nav_button_clicks();
});