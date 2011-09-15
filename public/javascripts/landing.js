function handle_nav_button_clicks() {
	$('a.next').click(function() {
		var height = $(window).height();
		var $next = $("#" + $(this).attr('goto'));
		$('body').animate({scrollTop: $next.offset().top},'slow');
	});
	$('a.top-link').click(function() {
		$('body').animate({scrollTop: 0},'slow');
	});
}

function handle_window_resize() {
	$(window).bind('resize', function(){
		$('.page').css({'height': ($(window).height())});
	});
}

$(document).ready(function() {
	$('.page') .css({'height': ($(window).height())});
	handle_nav_button_clicks();
	handle_window_resize();
});