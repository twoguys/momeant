$(document).ready(function() {
	$("a.recommend:not(.disabled)").fancybox();
	$("a.disabled").click(function() {return false;})
});