// Grid thumbnail interactions

function setup_thumbnail_hovers() {
  $('#discovery-grid li:not(.handled)').hoverIntent(function() {
    $(this).find('.hover').stop(true,true).fadeIn(200);
  }, function() {
    $(this).find('.hover').stop(true,true).fadeOut(200);
  });
}
setup_thumbnail_hovers();

// Twitter/Facebook linking

function discovery_configuration_complete(service, full) {
  if (full) {
    var $list = $('#activity-list');
    $list.addClass('loading');
    $.get('/auth/' + service + '/check', function(result) {
  		if(result) {
  		  $.get('/people/friends/reload_full', function(result) {
  		    $list.removeClass('loading').html(result);
  		    $('#link-' + service).replaceWith('<span>' + service.charAt(0).toUpperCase() + service.slice(1) + ' linked</span>');
  		  });
  		}
  	});
  } else {
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
}
$('#link-twitter').click(function() {
  var url = $(this).attr('href');
  var full = $(this).hasClass('full');
  window.oauth_twitter_window = window.open(url,'Twitter Configuration','height=500,width=900');
	window.oauth_twitter_interval = window.setInterval(function() {
		if (window.oauth_twitter_window.closed) {
			window.clearInterval(window.oauth_twitter_interval);
			discovery_configuration_complete('twitter', full);
		}
	}, 1000);
	return false;
});
$('#link-facebook').click(function() {
  var url = $(this).attr('href');
  var full = $(this).hasClass('full');
  window.oauth_facebook_window = window.open(url,'Facebook Configuration','height=500,width=900');
	window.oauth_facebook_interval = window.setInterval(function() {
		if (window.oauth_facebook_window.closed) {
			window.clearInterval(window.oauth_facebook_interval);
			discovery_configuration_complete('facebook', full);
		}
	}, 1000);
	return false;
});
  

// Infinite scrolling

var total_height, current_scroll, visible_height, buffer, current_page, stop_scrolling;
total_height = $('#main').height();
visible_height = document.documentElement.clientHeight;
buffer = -120;
current_page = 1;
stop_scrolling = false;
function monitor_scrolling() {
  if (stop_scrolling) { return; }

  current_scroll = $('#container').scrollTop();
  if (total_height <= current_scroll + visible_height + buffer) {
    current_page += 1;
    $.get('/discover', {page: current_page, remote: true}, function(result) {
      $('#discovery-grid').append(result);
      total_height = $('#main').height();
      
      if ($.trim(result) == '') {
        $('#discovery-loading').addClass('done').html('No more content');
        stop_scrolling = true;
      }
    });
  }
}  
$('#container').scroll(monitor_scrolling);
$(window).resize(function() {
  visible_height = document.documentElement.clientHeight;
});
$('#container').scrollTo(0);