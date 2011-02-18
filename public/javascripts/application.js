function setup_tooltips() {
	$('.tooltipped').tipsy();
	$('.tooltipped-n').tipsy({gravity:'s'});
	$('.tooltipped-w').tipsy({gravity:'e'});
}

function setup_tab_switching() {
	$('.tabs a').click(function() {
		$(this).addClass('active').siblings().removeClass('active');
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

function setup_topics_menu() {
	
}

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
	setup_signup_modal();
	setup_topics_menu();
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}