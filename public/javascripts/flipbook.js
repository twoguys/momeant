var flipbook;
var flipbook_manager = function() {
	this.slide_count = 0;
	this.current_slide = 1;
	this.width = 950;
	this.left_arrow = null;
	this.right_arrow = null;
	
	this.initialize = function() {
		this.left_arrow = $('#flipbook .controls .left');
		this.right_arrow = $('#flipbook .controls .right');
		this.left_arrow.click(flipbook.goto_previous_page);
		this.right_arrow.click(flipbook.goto_next_page);
		this.slide_count = $('#flipbook .flipstrip .slides .slide').length;
		this.handle_slide_click();
		this.update_arrow_visibility();
	};
	
	this.handle_slide_click = function() {
		$('#flipbook .flipstrip .slides .slide').click(flipbook.goto_next_page);
		$('#flipbook .flipstrip .slides .slide:last-child').click(flipbook.goto_first_page);
	};
	
	this.goto_previous_page = function() {
		if (flipbook.current_slide > 1) {
			$('#flipbook .flipstrip .slides').stop().animate({
				left: '+=' + flipbook.width + 'px'
			}, 400);
			flipbook.current_slide -= 1;
			flipbook.update_arrow_visibility();
		}
	};
	
	this.goto_next_page = function() {
		if (flipbook.current_slide < flipbook.slide_count) {
			$('#flipbook .flipstrip .slides').stop().animate({
				left: '-=' + flipbook.width + 'px'
			}, 400);
			flipbook.current_slide += 1;
			flipbook.update_arrow_visibility();
		}
	};
	
	this.goto_first_page = function() {
		$('#flipbook .flipstrip .slides').stop().animate({
			left: '0'
		}, 400);
		flipbook.current_slide = 1;
	};
	
	this.update_arrow_visibility = function() {
		if (flipbook.current_slide > 1) {
			flipbook.left_arrow.show();
		} else {
			flipbook.left_arrow.hide();
		}
		
		if (flipbook.current_slide < flipbook.slide_count) {
			flipbook.right_arrow.show();
		} else {
			flipbook.right_arrow.hide();
		}
	};
}

$(document).ready(function() {
	flipbook = new flipbook_manager();
	flipbook.initialize();
});