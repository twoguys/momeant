$(function() {
	
	$('.occupation, .location, .first_name, .last_name, .email, .amazon_email').each(function() {
	  var $element = $(this).find('.text');
	  $element.editInPlace({
  		url: '/users/' + user_id + '/update_in_place',
  		params: "attribute=" + $element.attr('update'),
  		field_type: "text",
  		show_buttons: true,
  		default_text: "(Click here to edit your " + $element.attr('update').replace('_',' ') + ")"
  	});
	});
	
	$('.tagline .text').editInPlace({
		url: '/users/' + user_id + '/update_in_place',
		params: "attribute=tagline",
		field_type: "textarea",
		textarea_rows: "2",
		textarea_cols: "50",
		show_buttons: true,
		default_text: "(Click here to edit - 150 characters or less)"
	});
	
	
	var $uploader = $('.file-uploader');
	var $preview = $('.avatar-badge-name .avatar')
	var $loader = $uploader.find('.loader');
	var $file_input = $uploader.find('input[type="file"]');
	var url = '/users/' + user_id + '/update_avatar';

	var uploader = $file_input.html5_upload({
		url: url,
		autostart: true,
		sendBoundary: true,
		fieldName: 'avatar',
		onStart: function() {
			$loader.show().siblings().hide();
			return true;
		},
		onFinishOne: function(event, response, name, number, total) {
			json = $.parseJSON(response);
			$preview.find('img').remove();
			$preview.append('<img src="' + json.url + '">');
			$loader.hide().siblings().show();
		}
	});
	
});