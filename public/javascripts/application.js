var currently_editing_text = false;

function setup_tooltips() {
	var opacity_setting = 1;
	$('.tooltipped').tipsy({opacity:opacity_setting});
	$('.tooltipped-n').tipsy({opacity:opacity_setting,gravity:'s'});
	$('.tooltipped-w').tipsy({opacity:opacity_setting,gravity:'e'});
	$('.tooltipped-e').tipsy({opacity:opacity_setting,gravity:'w'});
}

function setup_tab_switching() {
	$('.tabs a').click(function() {
		var $tab = $(this);
		$tab.addClass('active').siblings().removeClass('active');
		var $content = $tab.parent().siblings('.' + $tab.attr('href'));
		$content.show().siblings('.tabcontent').hide();
		return false;
	});
}

function setup_placeholder_text() {
	$('input[placeholder],textarea[placeholder]').placeholder();
}

function tag_deletions() {
	$('.tag a.remove').click(function() {
		var $parent = $(this).parent();
		$parent.bind("ajax:success", function(event, data, status, xhr) {
			$parent.hide();
		});
	});
}

function setup_modals() {
	_.each(['#join', '#login', '#feedback', '#about-diagram', '#about'], function(id) {
		$('a[href="' + id + '-modal"]').click(function() {
			$(id + '-modal').fadeIn('fast');
			var modal_name = id.slice(1);
			if (modal_name == 'login') { $('#login_email').focus(); }
			else if (modal_name == 'join') { $('#user_first_name').focus(); }
			modal_name = modal_name.charAt(0).toUpperCase() + modal_name.slice(1);
			mixpanel.track('Opened ' + modal_name + ' Modal');
			return false;
		})
		$(id + '-modal .cover, ' + id + '-modal .close').click(function() {
			$(id + '-modal').stop().fadeOut('fast');
			return false;
		});
		$(id + '-modal input').focus(function() {
		  currently_editing_text = true;
		});
		$(id + '-modal input').blur(function() {
		  currently_editing_text = false;
		});
	});
	
	$(document).keyup(function(e) {
	  if (e.keyCode == 27) { // escape key
			$('#join-modal, #login-modal, #feedback-modal, #about-diagram-modal').stop().fadeOut('fast');
		}
	});
	
	$('.modal .steps .buttons a').click(function() {
	  var $link = $(this);
	  var width = $link.parent().parent().width();
	  var $steps = $link.parents('.steps');
	  var current_margin = parseInt($steps.css('margin-left').replace('px',''));
	  if ($link.hasClass('next-step')) {
	    if ($link.attr('href') == '#join-modal') {
	      $('#about-modal').hide();
	    } else {
	      $steps.css('margin-left', current_margin - width);
	    }
	  } else {
	    $steps.css('margin-left', current_margin + width);
	  }
	  return false;
	});
	
	if (window.location.href.indexOf('#signup') >= 0) {
	  $('#join-modal').fadeIn(200);
	}
	var need_to_login_alert = $('#flash .alert:contains("You need to log in")').length > 0;
	var invalid_login_alert = $('#flash .alert:contains("Invalid email or password")').length > 0;
	if (need_to_login_alert || invalid_login_alert) {
	  $('#login-modal').fadeIn(200);
	  $('#login_email').focus();
	}
}

function handle_signup_login_form_validation() {
	// we have to remove the extra checkbox Rails inserts for the 0 value
	$('#join-form input[name="user[tos_accepted]"][value="0"]').remove();
	var $beta_join_button = $('#beta-join-form input[type="submit"]');
	$('#join-form').validate({
		rules: {
			'user[first_name]': 'required',
			'user[last_name]': 'required',
			'user[email]': {required:true,email:true},
			'user[password]': {required:true,minlength:6},
			'user[tos_accepted]': {required:true}
		},
		messages: {
			'user[first_name]':'Required',
			'user[last_name]':'Required',
			'user[email]':{required:'Required'},
			'user[password]':{required:'Required'},
			'user[tos_accepted]': {required:'Must be accepted'}
		}
	});
	$('#login-form').validate({
		rules: {
			'user[email]': {required:true,email:true},
			'user[password]': 'required'
		},
		messages: {
			'user[email]':{required:'Required'},
			'user[password]':'Required'
		}
	});
}

function handle_feedback_form() {
	$('#feedback-form').submit(function(event) {
		event.preventDefault(); 

		var $form = $(this);
		var comment = $form.find("#feedback_comment");
		var url = $form.attr('action');
		
		$.post(url, { comment:comment.val() });
		
		comment.val('');
		$('#feedback-modal .before').fadeOut(200, function() {
		  $('#feedback-modal .after').fadeIn(200);
		  setTimeout(function() {
		    $('#feedback-modal .after').fadeOut(200, function() {
    		  $('#feedback-modal .before').fadeIn(200);
  		  });
		  }, 2000);
		});
	});
}

function setup_oauth_process() {
	$('#share a.configure').click(function() {
		var service = $(this).attr('service');
		var callback = function() {
			var $service = $('#share #' + service);
			$.get('/auth/' + service + '/check', function(result) {
				if(result) {
					$service.find('a.configure').remove();
					$service.append('<input type="checkbox" value="1" name="' + service + '" id="' + service + '" checked=checked">');
					$('#share_' + service).val('yes');
				}
			});
		};
		window.oauth_window = window.open($(this).attr('href'),'Linking ' + service,'height=500,width=900');
		window.oauth_interval = window.setInterval(function() {
			if (window.oauth_window.closed) {
				window.clearInterval(window.oauth_interval);
				callback();
			}
		}, 1000)
		return false;
	});
}

function handle_activity_height() {
  var page_height = $('body').height();
  $('#community #activity-body').css('min-height', page_height - 135 + 'px');
  $('#community #activity-sidebar').css('min-height', page_height - 155 + 'px');
  $('#users #activity-body').css('min-height', page_height - 355 + 'px');
  $('#users #activity-sidebar').css('min-height', page_height - 375 + 'px');
}

function setup_reward_visualizing() {
	$('li.reward .visualize a').fancybox();
}

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
	setup_modals();
	handle_signup_login_form_validation();
	handle_feedback_form();
	setup_reward_visualizing();
	setup_oauth_process();
	handle_activity_height();
	
	$("a.disabled").click(function() {return false;})
	
	// auto-launch the about diagram modal if it exists (after new signups)
	$('a[href="#about-diagram-modal"]').click();
	
	$.fn.colorPicker.defaultColors = ['000', '666', '999', 'ccc', 'fff', 'f42652', 'f7d3db', 'ffa801', 'ffebc5', 'fff10f', 'fffcd2', '1ea337', 'c8f2d0', '00aeef', 'c0eeff', '985faf', 'f5deff', '7a5116', 'e1d5c3'];
	
	$('#header #search input[name="utf8"]').remove();
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}

function get_query_param(name) {
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.search);
  if(results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}


function show_feed_plus_one() {
  $('#feed-plus-one').show();
  setTimeout(function() {
    $('#feed-plus-one').fadeOut(500);
  }, 3000);
}