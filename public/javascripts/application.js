function setup_tooltips() {
	$('.tooltipped').tipsy();
	$('.tooltipped-n').tipsy({gravity:'s'});
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

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
	tag_deletions();
});

function log(message) {
	if (console && console.log) {
		console.log(message);
	}
}