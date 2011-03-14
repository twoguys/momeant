function setup_search_placeholder() {
	$('.beta input[type="text"]').focus(function(){
		$(this).val('').removeClass('placeholder');
	});
}

$(document).ready(function(){
	setup_search_placeholder();
});