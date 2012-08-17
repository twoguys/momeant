$(function() {
  
  var $uploader = $('.file-uploader');
  var $preview = $('.avatar-badge .avatar');
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
      mixpanel.track('Uploaded Avatar');
    }
  });
  
  $('#settings-list .text').click(function() {
    $(this).siblings('input').click();
  });
  
  $('#settings-list input').click(function() {
    var checkbox = $(this);
    var setting = checkbox.attr('id');
    var text = checkbox.siblings('.text');
    text.addClass('loading');
    $.post('/users/' + user_id + '/update_email_setting', {attribute: setting}, function(data) {
      text.removeClass('loading');
    });
  });
  
});
