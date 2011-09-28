$(document).ready(function() {
	$('.gallery li.about .description').editInPlace({
		url: "/blah",
		field_type: "textarea",
		textarea_rows: "14",
		textarea_cols: "27",
		show_buttons: true
	});
});