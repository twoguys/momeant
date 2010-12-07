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

function setup_personal_library_tabs() {
	$('#your-purchases').click(function() {
		$('.personal-library .bookmarks').hide();
		$('.personal-library .purchases').show();
		return false;
	});
	$('#your-bookmarks').click(function() {
		$('.personal-library .purchases').hide();
		$('.personal-library .bookmarks').show();
		return false;
	});
}

$(document).ready(function() {
	setup_recommendation_tabs();
	setup_personal_library_tabs();
});