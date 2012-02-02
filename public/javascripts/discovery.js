$(function() {
  $('#link-twitter').click(function() {
    var url = $(this).attr('href');
    window.oauth_twitter_window = window.open(url,'Twitter Configuration','height=500,width=900');
		window.oauth_twitter_interval = window.setInterval(function() {
			if (window.oauth_twitter_window.closed) {
				window.clearInterval(window.oauth_twitter_interval);
				discovery_configuration_complete('twitter');
			}
		}, 1000);
		return false;
  });
  $('#link-facebook').click(function() {
    var url = $(this).attr('href');
    window.oauth_facebook_window = window.open(url,'Facebook Configuration','height=500,width=900');
		window.oauth_facebook_interval = window.setInterval(function() {
			if (window.oauth_facebook_window.closed) {
				window.clearInterval(window.oauth_facebook_interval);
				discovery_configuration_complete('facebook');
			}
		}, 1000);
		return false;
  });
});

function discovery_configuration_complete(service) {
  var $list = $('#friends-you-know ul.mini-activity');
  $list.addClass('loading');
  $.get('/auth/' + service + '/check', function(result) {
		if(result) {
		  $.get('/people/friends/reload', function(result) {
		    $list.removeClass('loading').html(result);
		    $('#link-' + service).replaceWith('<span>' + service.charAt(0).toUpperCase() + service.slice(1) + ' linked</span>');
		  });
		}
	});
}