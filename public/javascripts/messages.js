function setup_message_posting() {
  $('#message-reply textarea').autoResize({
    extraSpace: 20
  });
  
	$('#message-reply').submit(function(event) {
		event.preventDefault();

		var $form = $(this);
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
				"message[recipient_id]":recipient_id,
				"remote":true
			},
			function(data) {
				$form.find('#message_body, input[type="submit"]').removeAttr('disabled').removeClass('loading');
				if (data.success) {
					var html = '<li><img src="' + data.avatar + '" class="avatar" alt="Thumbnail">';
					html += '<div class="body">' + body + '</div><div class="when">just now</div></li>';
					$('ul#full-messages').append(html);
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