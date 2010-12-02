function setupTooltips() {
	$('.tooltipped').tipsy();
	$('.tooltipped-n').tipsy({gravity:'s'});
}

$(document).ready(function() {
	setupTooltips();
});