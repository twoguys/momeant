$(function() {
  
  // Swapping between signup/login
  $('#show-join').click(function() {
    $('#forms #login').fadeOut();
    $('#forms #join').fadeIn();
    $('#forms').animate({height:'475px'}, 200);
    return false;
  });
  $('#show-login').click(function() {
    $('#forms #join').fadeOut();
    $('#forms #login').fadeIn();
    $('#forms').animate({height:'400px'}, 200);
    return false;
  });
  
  // Form validations
	// we have to remove the extra checkbox Rails inserts for the 0 value
	$('#creators-join-form input[name="user[tos_accepted]"][value="0"]').remove();
	$('#creators-join-form').validate({
		rules: {
		  'user[invitation_code]': 'required',
			'user[first_name]': 'required',
			'user[last_name]': 'required',
			'user[email]': {required:true,email:true},
			'user[password]': {required:true,minlength:6},
			'user[tos_accepted]': {required:true}
		},
		messages: {
		  'user[invitation_code]': 'Required',
			'user[first_name]':'Required',
			'user[last_name]':'Required',
			'user[email]':{required:'Required'},
			'user[password]':{required:'Required'},
			'user[tos_accepted]': {required:'Must be accepted'}
		}
	});
	$('#creators-login-form').validate({
		rules: {
		  'user[invitation_code]': 'required',
			'user[email]': {required:true,email:true},
			'user[password]': 'required'
		},
		messages: {
		  'user[invitation_code]': 'Required',
			'user[email]':{required:'Required'},
			'user[password]':'Required'
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