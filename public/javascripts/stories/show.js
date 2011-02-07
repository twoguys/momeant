var viewer;
var story_viewer = function() {
	
	this.page = 1;
	this.total_pages = 0;
	this.previewer_open = true;
	
	this.initialize = function() {
		viewer.total_pages = parseInt($('#number-of-pages').text());
		
		$('#previewer').hover(viewer.open_previewer, viewer.close_previewer);
		$('#next-page').hover(viewer.show_next_button, viewer.hide_next_button);
		$('#previous-page').hover(viewer.show_prev_button, viewer.hide_prev_button);
		
		$('#next-page').click(viewer.goto_next_page);
		$('#previous-page').click(viewer.goto_prev_page);
		
		$('#previewer ul.pages li').click(viewer.previewer_page_clicked);
		
		update_previewer_width();
		viewer.set_active_preview(1);
		hide_controls_after_initial_delay();
	};
	
	this.open_previewer = function() {
		$('#previewer').stop().animate({bottom: '0px'}, 500);
	};
	
	this.close_previewer = function() {
		$('#previewer').stop().animate({bottom: '-215px'}, 500);
	};
	
	this.show_next_button = function() {
		if (viewer.page < viewer.total_pages) {
			$('#next-page .button').stop().animate({opacity: 1});
		}
	};
	
	this.hide_next_button = function() {
		var opacity_level = viewer.page == viewer.total_pages ? 0 : .3;
		$('#next-page .button').stop().animate({opacity: opacity_level});
	};
	
	this.show_prev_button = function() {
		if (viewer.page > 1) {
			$('#previous-page .button').stop().animate({opacity: 1});
		}
	};

	this.hide_prev_button = function() {
		var opacity_level = viewer.page == 1 ? 0 : .3;
		$('#previous-page .button').stop().animate({opacity: opacity_level});
	};
	
	this.previewer_page_clicked = function() {
		var page_number = parseInt($(this).attr('page-number'));
		viewer.goto_page(page_number);
	};
	
	this.set_active_preview = function(page_number) {
		$('#previewer ul.pages li[page-number="' + page_number + '"]').addClass('active').siblings().removeClass('active');
	};
	
	this.goto_next_page = function() {
		viewer.goto_page(viewer.page + 1);
	};
	
	this.goto_prev_page = function() {
		viewer.goto_page(viewer.page - 1);
	};
	
	this.goto_page = function(page_number) {
		if (page_number >= 1 && page_number <= viewer.total_pages && page_number != viewer.page) {
			var $current_page = $('#page_' + viewer.page);
			var $next_page = $('#page_' + page_number);
			$current_page.fadeOut();
			$next_page.fadeIn();
			var previous_page_number = viewer.page;
			viewer.set_active_preview(page_number);
			viewer.page = page_number;
			
			if (page_number == 1) {
				viewer.hide_prev_button();
			}
			if (page_number == viewer.total_pages) {
				viewer.hide_next_button();
			}
			if (previous_page_number == 1) {
				// bring the prev button from opacity 0 to .3
				viewer.hide_prev_button();
			}
		}
	};
	
	var update_previewer_width = function() {
		var width = viewer.total_pages * 290;
		$('#previewer ul.pages').css('width', width + 'px');
	};
	
	var hide_controls_after_initial_delay = function() {
		setTimeout(function() {
				viewer.close_previewer();
				viewer.hide_next_button();
				viewer.hide_prev_button();
			}, 2000);
	};
	
}

$(document).ready(function() {
	viewer = new story_viewer();
	viewer.initialize();
});