function setup_toggling_adverts() {
	$('.admin .adverts .enabled input').click(function() {
		var $checkbox = $(this);
		var $label = $(this).siblings('span');
		var $spinner = $(this).siblings('img');
		toggle_advert_enabled($checkbox, $label, $spinner, $checkbox.val(), $checkbox.is(':checked'));
	});
}

function toggle_advert_enabled($checkbox, $label, $spinner, id, enabled) {
	$checkbox.hide();
	$spinner.show();
	$.post('/admin/adverts/' + id + '/toggle_enabled',
		function(data) {
			if (data.result == "success") {
				if (enabled) {
					$label.text('enabled').removeClass('disabled');
				} else {
					$label.text('disabled').addClass('disabled');
				}
				$spinner.hide();
				$checkbox.show();
			} else {
				log('error toggling advert: ' + id);
			}
		}
	);
}

$(document).ready(function() {
	setup_toggling_adverts();
});