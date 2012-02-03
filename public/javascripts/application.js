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
	_.each(['#join', '#login', '#feedback', '#about-diagram'], function(id) {
		$('a[href="' + id + '-modal"]').click(function() {
			$(id + '-modal').fadeIn('fast');
			return false;
		})
		$(id + '-modal .cover, ' + id + '-modal .close').click(function() {
			$(id + '-modal').stop().fadeOut('fast');
			return false;
		});
	});
	
	$(document).keyup(function(e) {
	  if (e.keyCode == 27) { // escape key
			$('#join-modal, #login-modal, #feedback-modal, #about-diagram-modal').stop().fadeOut('fast');
		}
	});
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
		$('#feedback-modal').fadeOut('fast');
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
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}

// http://github.com/splendeo/jquery.observe_field
jQuery.fn.observe_field = function(frequency, callback) {

  return this.each(function(){
    var element = $(this);
    var prev = element.val();

    var chk = function() {
      var val = element.val();
      if(prev != val){
        prev = val;
        element.map(callback); // invokes the callback on the element
      }
    };
    chk();
    var new_frequency = frequency * 1000; // translate to milliseconds
    var ti = setInterval(chk, new_frequency);
    // reset counter after user interaction
    element.bind('keyup', function() {
      ti && clearInterval(ti);
      ti = setInterval(chk, new_frequency);
    });
  });

};