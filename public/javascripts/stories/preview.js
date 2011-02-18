$(document).ready(function() {
	$("a.recommend:not(.disabled)").fancybox({
		onComplete: function() {
			$("#recommend-modal textarea").focus();
		}
	});
	$("a.disabled").click(function() {return false;})
});