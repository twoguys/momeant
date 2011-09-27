function hide_thumbnails_that_dont_fit() {
	var window_width = $(document).width();
	window_width -= 260; // subtract user info column
	
	var thumbnail_width = 245;
	var number_of_thumbnails_that_fit = Math.floor(window_width / thumbnail_width);
	number_of_thumbnails_that_fit -= 1; // bump down because jQuery's selector is zero-based
	$('table.users tr').each(function() {
		var $row = $(this);
		$row.find('ul.rewards li:lt(' + (number_of_thumbnails_that_fit + 1) + ')').show();
		$row.find('ul.rewards li:gt(' + number_of_thumbnails_that_fit + ')').hide();
	});
}

$(document).ready(function() {
	hide_thumbnails_that_dont_fit();
	$(window).resize(hide_thumbnails_that_dont_fit);
});