function handle_nav_button_clicks() {
	var height = $('#landing #insides').height();
	var $letter = $('#letter');
	var $next = $('#landing a.next');
	var $previous = $('#landing a.previous');

	$next.click(function() {
		if ($next.hasClass('disabled'))
			return;
			
		$next.addClass('disabled');
		$letter.animate({top: '-=' + height}, 300, function() {
			$next.removeClass('disabled');
			$previous.show();
			log($letter.css('top'));
			if ($letter.css('top') == '-900px')
				$next.hide();
		});
	});
	$previous.click(function() {
		if ($previous.hasClass('disabled'))
			return;
			
		$previous.addClass('disabled');
		$letter.animate({top: '+=' + height }, 300, function() {
			$previous.removeClass('disabled');
			$next.show();
			if ($letter.css('top') == '0px')
				$previous.hide();
		});
	});
}

$(document).ready(function() {
	handle_nav_button_clicks();
});