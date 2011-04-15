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
	$('#join').click(function() {
		var $modal = $('#join-login-modal');
		$modal.stop().fadeIn('fast');
		return false;
	});
	$('#join-login-modal .cover').click(function() {
		$('#join-login-modal').stop().fadeOut('fast');
	});
	$(document).keyup(function(e) {
	  if (e.keyCode == 27) { $('#join-login-modal').stop().fadeOut('fast'); } // escape
	});
}

function setup_recommend_modal() {
	$("a.recommend:not(.disabled)").fancybox({
		scrolling: 'no',
		onComplete: function() {
			$("#recommend-modal textarea").focus();
		}
	});
}

function setup_search_placeholder() {
	$('#query').focus(function(){
		$(this).val('');
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

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
	setup_signup_modal();
	setup_recommend_modal();
	setup_search_placeholder();
	setup_story_gallery();
	setup_recommendation_tabs();
	//setup_personal_library_tabs();
	$("a.disabled").click(function() {return false;})
	
	$.fn.colorPicker.defaultColors = ['000', '333', '666', '999', 'ccc', 'fff'];
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}