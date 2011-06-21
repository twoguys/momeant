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

function setup_signup_modal() {
	$('#join, a[href="#signup-modal"]').click(function() {
		var $modal = $('#join-login-modal');
		$modal.stop().fadeIn('fast');
		return false;
	});
	$('#join-login-modal .cover, #join-login-modal .close').click(function() {
		$('#join-login-modal').stop().fadeOut('fast');
	});
	$(document).keyup(function(e) {
	  if (e.keyCode == 27) { $('#join-login-modal').stop().fadeOut('fast'); } // escape
	});
}

function setup_rewarding() {
	$("a.reward:not(.disabled), a.rewarded:not(.disabled)").fancybox({scrolling: 'no'});
	$('#reward-form ul.coins li').click(function() {
		var $coin = $(this);
		$coin.addClass('selected').find('input').attr('checked', true);
		$coin.siblings().removeClass('selected').find('input').attr('checked', false);
	});
	$('#reward-form').submit(function(event) {
		event.preventDefault(); 

		var $form = $(this);
		var amount = $form.find('input:radio[name="reward[amount]"]:checked').val();
		var comment = $form.find("#reward_comment").val();
		var url = $form.attr('action');

		$('#reward-box').addClass('loading');
		$.post(url, { "reward[amount]":amount, "reward[comment]":comment }, function(data) {
			$("#reward-box .inner").html(data);
			$('#reward-box').removeClass('loading');
			$('.story-preview .actions a.reward').removeClass('reward').addClass('rewarded').attr('title','You rewarded this story.');
		});
	});
}

function setup_story_gallery() {
	if ($('.story-gallery .scrollbar-me').length > 0 ) {
		var small_preview_width = 100, large_preview_width = 630;
		var count = $('.scrollbar-me .overview .preview').length;
		$('.story-gallery .scrollbar-me .overview').css('width', count * small_preview_width);
		$('.story-gallery .scrollbar-me').tinyscrollbar({axis:'x'});
		$('.story-gallery .preview').click(function() {
			var page = $(this).attr('counter');
			var position = page * large_preview_width;
			$('.story-gallery .large-preview').scrollTo({top: 0, left: position}, {duration: 200});
		});
	}
	if ($('.story-gallery').length > 0) {
		var story_count = $('.story-gallery .large-preview .pages a').length;
		$('.story-gallery .large-preview .pages').css('width', story_count * 630);
	}
}

function setup_recommendation_tabs() {
	$('#subscribed-to-recommendations').click(function() {
		$('.momeant-recommended-stream').hide();
		$('.subscribed-to-stream').show();
		return false;
	});
	$('#momeant-recommendations').click(function() {
		$('.subscribed-to-stream').hide();
		$('.momeant-recommended-stream').show();
		return false;
	});
}

function setup_thumbnail_flipping() {
	$('ul.stories li.story.medium').hover(function(){$(this).addClass('flip')},function(){$(this).removeClass('flip')});
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

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
	setup_signup_modal();
	setup_rewarding();
	setup_story_gallery();
	setup_recommendation_tabs();
	setup_thumbnail_flipping();
	handle_signup_login_form_validation();
	$("a.disabled").click(function() {return false;})
	
	$.fn.colorPicker.defaultColors = ['000', '666', '999', 'ccc', 'fff', 'f42652', 'f7d3db', 'ffa801', 'ffebc5', 'fff10f', 'fffcd2', '1ea337', 'c8f2d0', '00aeef', 'c0eeff', '985faf', 'f5deff', '7a5116', 'e1d5c3'];
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}