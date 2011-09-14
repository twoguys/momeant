function handle_creator_row_clicks() {
	$('table.users tr.user').click(function() {
		var $row = $(this);
		var $content_row = $('table.users tr#content_for_' + $row.attr('user_id'));
		if ($row.hasClass('open')) {
			$row.removeClass('open');
			$content_row.hide();
		} else {
			$row.addClass('open');
			$content_row.show();
		}
	});
}

$(document).ready(function() {
	handle_creator_row_clicks();
});