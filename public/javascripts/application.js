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
	_.each(['#join', '#login', '#feedback'], function(id) {
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
	  if (e.keyCode == 27) { $('#join-modal, #login-modal, #feedback-modal').stop().fadeOut('fast'); } // escape
	});
}

function setup_rewarding() {
	$('#reward-form').submit(function(event) {
		event.preventDefault(); 

		var $form = $(this);
		var amount = $form.find('#reward_amount').val();
		var comment = $form.find("#reward_comment").val();
		var story_id = $form.find("#reward_story_id").val();
		var impacted_by = $form.find("#reward_impacted_by").val();
		var url = $form.attr('action');

		$('#give-reward').addClass('loading');
		$.post(url,
			{
				"reward[amount]":amount,
				"reward[comment]":comment,
				"reward[story_id]":story_id,
				"reward[impacted_by]":impacted_by
			},
			function(data) {
				$("#give-reward").html(data);
				$('#give-reward').removeClass('loading').addClass('thanks');
				var $new_reward = $('#new-reward');
				$new_reward.find('.amount').text(amount);
				$new_reward.find('.comment').text(comment);
				$new_reward.slideDown();
			}
		);
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

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
	setup_modals();
	setup_rewarding();
	handle_signup_login_form_validation();
	handle_feedback_form();
	
	$("a.disabled").click(function() {return false;})
	
	$.fn.colorPicker.defaultColors = ['000', '666', '999', 'ccc', 'fff', 'f42652', 'f7d3db', 'ffa801', 'ffebc5', 'fff10f', 'fffcd2', '1ea337', 'c8f2d0', '00aeef', 'c0eeff', '985faf', 'f5deff', '7a5116', 'e1d5c3'];
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}