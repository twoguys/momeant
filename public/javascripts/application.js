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

$(document).ready(function() {
	setup_tooltips();
	setup_tab_switching();
	setup_placeholder_text();
});