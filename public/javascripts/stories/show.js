var viewer;
var story_viewer = function() {
	
	this.page = 1;
	this.total_pages = 0;
	this.previewer_open = true;
	
	this.initialize = function() {
		viewer.total_pages = parseInt($('#number-of-pages').text());
		
		$('#next-page').click(viewer.goto_next_page);
		$('#previous-page').click(viewer.goto_prev_page);
		$('ul#pages li').swipe({swipe:viewer.swipe,threshold:0});
		//$('#activity-flag, #close-activity').click(function(){$('#activity').toggle();});
		$.scrollTo('42');
		setup_page_number_clicking();
		setup_key_bindings();
		goto_page_in_url_or_hide_prev_button();
	};
	
	this.show_next_button = function() {
		$('#next-page').show();
	};
	
	this.hide_next_button = function() {
		$('#next-page').hide();
	};
	
	this.show_prev_button = function() {
		$('#previous-page').show();
	};

	this.hide_prev_button = function() {
		$('#previous-page').hide();
	};
	
	this.swipe = function(event, direction) {
		if (direction == "left") {
			viewer.goto_next_page();
		} else if (direction == "right") {
			viewer.goto_prev_page();
		}
	};
	
	var setup_page_number_clicking = function() {
		$('#metadata .pages a').click(function() {
			var page = parseInt($(this).text());
			viewer.goto_page(page);
			return false;
		});
	};
	
	var setup_key_bindings = function() {
		$(document).keyup(function(e) {
		  if (e.keyCode == 39) { viewer.goto_next_page(); } 		// right arrow
			if (e.keyCode == 37) { viewer.goto_prev_page(); }			// left arrow
		});
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
			viewer.page = page_number;
			$('#metadata .pages a[page="'+page_number+'"]').addClass('selected').siblings().removeClass('selected');
			
			if (page_number == 1) {
				viewer.hide_prev_button();
			} else {
				viewer.show_prev_button();
			}
			if (page_number == viewer.total_pages) {
				viewer.hide_next_button();
			} else {
				viewer.show_next_button();
			}			
		}
	};
	
	var goto_page_in_url_or_hide_prev_button = function() {
		var url = window.location.href;
		if (url.indexOf('#page') != -1) {
			var page = parseInt(url.substring(url.indexOf('#page') + 5));
			viewer.goto_page(page);
		} else {
			viewer.hide_prev_button();
		}
	};
}

$(document).ready(function() {
	viewer = new story_viewer();
	//viewer.initialize();
	
	$('#previewer a.rewarded, #previewer a.reward').click(function(event) {
		viewer.goto_page(viewer.total_pages);
		$('.viewport').scrollTo(viewer.total_pages * 210, 0);
		return false;
	});
});