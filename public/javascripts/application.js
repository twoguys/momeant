function setupTooltips() {
	$('.tooltipped').tipsy();
	$('.tooltipped-n').tipsy({gravity:'s'});
}

function setupTabSwitching() {
	$('.tabs a').click(function() {
		$(this).addClass('active').siblings().removeClass('active');
	});
}

$(document).ready(function() {
	setupTooltips();
	setupTabSwitching();
});