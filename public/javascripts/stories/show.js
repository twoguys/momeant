var viewer;
var story_viewer = function() {
	
	this.page = 1;
	this.total_pages = 0;
	this.previewer_open = true;
	
	this.initialize = function() {
		viewer.total_pages = parseInt($('#number-of-pages').text());
		
		$('#previewer .handle').click(viewer.toggle_previewer);
		$('#next-page').hover(viewer.show_next_button, viewer.hide_next_button);
		$('#previous-page').hover(viewer.show_prev_button, viewer.hide_prev_button);
		
		$('#next-page').click(viewer.goto_next_page);
		$('#previous-page').click(viewer.goto_prev_page);
		
		$('#previewer ul.pages li').click(viewer.previewer_page_clicked);
		
		$('ul#pages, #previous-page, #next-page').click(viewer.close_previewer);
		
		$('ul#pages li').swipe({swipe:viewer.swipe,threshold:0});
		
		update_previewer_width();
		viewer.set_active_preview(1);
		hide_controls_after_initial_delay();
		
		$.scrollTo('42');
		
		setup_key_bindings();
		
		goto_page_in_url();
	};
	
	this.open_previewer = function() {
		if (!viewer.previewer_open) {
			$('#previewer').stop().animate({bottom: '0px'}, 500).removeClass('closed').addClass('open');
			viewer.previewer_open = true;
		}
	};
	
	this.close_previewer = function() {
		if (viewer.previewer_open) {
			$('#previewer').stop().animate({bottom: '-215px'}, 500).removeClass('open').addClass('closed');
			viewer.previewer_open = false;
		}
	};
	
	this.toggle_previewer = function() {
		if (viewer.previewer_open)
			viewer.close_previewer();
		else
			viewer.open_previewer();
	};
	
	this.show_next_button = function() {
		if (viewer.page < viewer.total_pages) {
			$('#next-page .button').stop().animate({opacity: 1});
		}
	};
	
	this.hide_next_button = function() {
		$('#next-page .button').stop().animate({opacity: 0});
	};
	
	this.show_prev_button = function() {
		if (viewer.page > 1) {
			$('#previous-page .button').stop().animate({opacity: 1});
		}
	};

	this.hide_prev_button = function() {
		$('#previous-page .button').stop().animate({opacity: 0});
	};
	
	this.swipe = function(event, direction) {
		if (direction == "left") {
			viewer.goto_next_page();
		} else if (direction == "right") {
			viewer.goto_prev_page();
		}
	};
	
	var setup_key_bindings = function() {
		$(document).keyup(function(e) {
		  if (e.keyCode == 27) { viewer.toggle_previewer(); }   // esc
			if (e.keyCode == 39) { viewer.goto_next_page(); } 		// right arrow
			if (e.keyCode == 37) { viewer.goto_prev_page(); }			// left arrow
			//if (e.keyCode == 40) { viewer.close_previewer(); }		// down arrow
			//if (e.keyCode == 38) { viewer.open_previewer(); }			// up arrow
		});
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
			
			var x_coord = 200 * page_number;
			$('#previewer .viewport .overview').scrollLeft(x_coord);
		}
	};
	
	var update_previewer_width = function() {
		var width = viewer.total_pages * 300;
		$('#previewer .viewport .overview').css('width', width + 'px');
		$('#previewer .slider').css('width', $(window).width() - 280 + 'px');
		$('#previewer .scrollbar-me').tinyscrollbar({axis:'x'});
	};
	
	var hide_controls_after_initial_delay = function() {
		setTimeout(function() {
				viewer.close_previewer();
				viewer.hide_next_button();
				viewer.hide_prev_button();
			}, 2000);
	};
	
	var goto_page_in_url = function() {
		var url = window.location.href;
		if (url.indexOf('#page')) {
			var page = parseInt(url.substring(url.indexOf('#page') + 5));
			viewer.goto_page(page);
		}
	};
}

$(document).ready(function() {
	viewer = new story_viewer();
	viewer.initialize();
	
	$('#previewer a.rewarded, #previewer a.reward').click(function(event) {
		viewer.goto_page(viewer.total_pages);
		$('.viewport').scrollTo(viewer.total_pages * 210, 0);
		return false;
	});
});