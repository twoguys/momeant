$(function() {
  
  // Form validations
	// we have to remove the extra checkbox Rails inserts for the 0 value
	$('#creators-login-form input[name="creator[tos_accepted]"][value="0"]').remove();
	$('#creators-login-form').validate({
		rules: {
		  'creator[invitation_code]': 'required',
			'creator[email]': {required:true,email:true},
			'creator[password]': {required:true,minlength:6},
			'creator[tos_accepted]': {required:true}
		},
		messages: {
		  'creator[invitation_code]': 'Required',
			'creator[email]':{required:'Required'},
			'creator[password]':{required:'Required'},
			'creator[tos_accepted]': {required:'Must be accepted'}
		}
	});
  
  // Avatar uploading
  var $uploader = $('.file-uploader');
  if ($uploader.length > 0) {
    var $preview = $('#avatar-preview');
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
  }
  
});