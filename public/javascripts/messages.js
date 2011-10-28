function setup_message_posting() {
	$('#messages form').submit(function(event) {
		var $form = $(this);
		event.preventDefault(); 

		var body = $form.find('#message_body').val();
		if (body.length == 0) { return false; }
		var parent_id = $form.find('#message_parent_id').val();
		var url = $form.attr('action');
		
		$form.find('#message_body, input[type="submit"]').attr('disabled','disabled');
		$form.find('#message_body').val('').addClass('loading');
		$.post(url,
			{ "message[body]":body, "message[parent_id]":parent_id },
			function(data) {
				$form.find('#message_body, input[type="submit"]').removeAttr('disabled').removeClass('loading');
				if (data.success) {
					var html = '<li class="message"><img src="' + data.avatar + '" class="avatar" alt="Thumbnail">';
					html += '<div class="rest"><div class="text">' + body + '</div><div class="when">just now</div></div></li>';
					if ($form.hasClass('reply')) {
						$form.parent().find('ul.children').append(html);
					} else {
						$('ul#previous-messages').prepend(html);
					}
				} else {
					log('error');
				}
			}
		);
	});
}

function setup_reply_showing() {
	$('#messages .show-form').click(function() {
		$(this).hide().siblings('form').show();
		return false;
	});
}

$(function() {
	setup_message_posting();
	setup_reply_showing();
});