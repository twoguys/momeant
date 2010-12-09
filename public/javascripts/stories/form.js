var pages_editor;
var story_page_editor = function() {
	
	this.page = 1;
	this.page_chooser_open = true;
	
	this.initialize = function() {
		setup_page_editor_open_button();
		setup_page_editor_close_button();
		setup_page_layout_chooser();
		setup_next_page_button();
		setup_prev_page_button();
	};
	
	// SETUP
	
	var setup_page_editor_open_button = function() {
		$('#open-page-editor-button').click(function() {
			$('body').addClass('fullscreen');
			$('#page-editor').show().siblings().hide();
			$('#error-explanation').hide();
			return false;
		});
	};
	
	var setup_page_editor_close_button = function() {
		$('#close-page-editor-button').click(function() {
			$('body').removeClass('fullscreen');
			$('#page-editor').hide().siblings().show();
			$('#error-explanation').show();
			return false;
		});
	};
	
	var setup_page_layout_chooser = function() {
		$('#page-type-chooser .slider li').click(function() {
			var page_type = $(this).attr('page-type');
			pages_editor.choose_page_theme(page_type);
		});
		$('#page-type-chooser-button').click(function() {
			pages_editor.show_page_type_chooser();
		});
	};
	
	var setup_next_page_button = function()  {
		$('#next-page').click(pages_editor.goto_next_page);
	};
	
	var setup_prev_page_button = function()  {
		$('#previous-page').click(pages_editor.goto_previous_page);
	};
	
	// PAGE THEME CHOOSING
	
	this.choose_page_theme = function(page_type) {
		var $current_page = $('#page_' + pages_editor.page);
		//$current_page.hide();
		//$('#loader').show();
		$.get('/stories/render_page_theme?theme=' + page_type + '&page=' + pages_editor.page, function(result) {
			$current_page.html(result);
			$current_page.find('#input[placeholder],textarea[placeholder]').placeholder();
			//$('#loader').hide();
			$current_page.fadeIn();
			$current_page.click(pages_editor.hide_page_type_chooser);
			pages_editor.hide_page_type_chooser();
		});
	};
	
	// VISUAL CHANGES
	
	this.hide_page_type_chooser = function() {
		if (!pages_editor.page_chooser_open) {
			return;
		} else {
			$('#page-type-chooser, #pages').animate({ top: '-=160'}, 500, pages_editor.show_layout_chooser_button);
			pages_editor.page_chooser_open = false;
		}
	};
	
	this.show_page_type_chooser = function() {
		if (pages_editor.page_chooser_open) {
			return;
		} else {
			$('#page-type-chooser, #pages').animate({ top: '+=160'}, 500, pages_editor.hide_layout_chooser_button);
			pages_editor.page_chooser_open = true;
		}
	};
	
	this.show_layout_chooser_button = function() {
		$('#page-type-chooser-button').show();
		$('#page-type-chooser-button').animate({ bottom: '-40'}, 500);
	};
	
	this.hide_layout_chooser_button = function() {
		$('#page-type-chooser-button').animate({ bottom: 0}, 500);
	};
	
	this.goto_next_page = function() {
		if (pages_editor.page == 10) { return false; }
		pages_editor.change_page_by(1);
	};
	
	this.goto_previous_page = function() {
		if (pages_editor.page == 1) { return false; }
		pages_editor.change_page_by(-1);
	};
	
	this.change_page_by = function(difference) {
		var page = pages_editor.page;
		var $current_page = $('#page_' + page);
		var $next_page = $('#page_' + (page + difference));
		$next_page.fadeIn();
		$current_page.fadeOut();
		pages_editor.set_current_page(page + difference);
		if ($next_page.find('.page-theme').length == 0) {
			pages_editor.show_page_type_chooser();
		} else {
			pages_editor.hide_page_type_chooser();
		}
	}
	
	this.set_current_page = function(new_page) {
		this.page = new_page;
		$('#current_page .current').text(new_page);
		if (new_page == 1) {
			pages_editor.hide_previous_page_button();
		} else if (new_page == 2) {
			pages_editor.show_previous_page_button();
		} else if (new_page == 9) {
			pages_editor.show_next_page_button();
		} else if (new_page == 10) {
			pages_editor.hide_next_page_button();
		}
	};
	
	this.show_previous_page_button = function() {
		$('#previous-page').fadeIn();
	};
	
	this.show_next_page_button = function() {
		$('#next-page').fadeIn();
	};
	
	this.hide_previous_page_button = function() {
		$('#previous-page').fadeOut();
	};
	
	this.hide_next_page_button = function() {
		$('#next-page').fadeOut();
	};
	
}

$(document).ready(function() {
	pages_editor = new story_page_editor();
	pages_editor.initialize();
});