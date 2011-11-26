function setup_message_posting() {
	$('#messages-inner form').submit(function(event) {
		var $form = $(this);
		event.preventDefault(); 

		var body = $form.find('#message_body').val();
		if (body.length == 0) { return false; }
		var parent_id = $form.find('#message_parent_id').val();
		var recipient_id = $form.find('#message_recipient_id').val();
		var url = $form.attr('action');
		
		$form.find('#message_body, input[type="submit"]').attr('disabled','disabled');
		$form.find('#message_body').val('').addClass('loading');
		$.post(url,
			{
				"message[body]":body,
				"message[parent_id]":parent_id,
				"message[recipient_id]":recipient_id
			},
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
	
	$('#messages-inner form textarea').keypress(function(event) {
		if (event.which == 13 && $(this).val().trim() != "") {
			$(this).parent().submit();
		}
	});
}

function setup_reply_showing() {
	$('#messages-inner .show-form').click(function() {
		$(this).hide().siblings('form').show().find('textarea').focus();
		return false;
	});
}

$(function() {
	setup_message_posting();
	setup_reply_showing();
});