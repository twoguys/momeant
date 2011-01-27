function setup_new_credit_card_form_link() {
	$('#use-a-new-credit-card').click(function() {
		$('#new-credit-card-fields').toggle(500);
		return false;
	})
}

$(document).ready(function() {
	setup_new_credit_card_form_link();
});