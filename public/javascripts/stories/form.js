var pages_editor;
var story_page_editor = function() {
	
	this.page = 1;
	this.page_chooser_open = true;
	this.page_type_css_classes = 'title full_image pullquote video split';
	
	this.initialize = function() {
		$('#open-page-editor-button').click(pages_editor.open);
		$('#close-page-editor-button').click(pages_editor.close);
		setup_page_layout_chooser();
		setup_next_page_button();
		setup_prev_page_button();
		setup_preview_clicking();
		setup_preview_thumbnailing();
		setup_grid_editing();
		initialize_first_page();
	};
	
	// SETUP
	
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
	
	var setup_preview_clicking = function() {
		$('#page-previews li.page').click(function() {
			var page_number = $(this).attr('page-number');
			pages_editor.goto_page(page_number);
			var chosen = $(this).hasClass('chosen');
			if (chosen)
				pages_editor.hide_page_type_chooser();
			else
				pages_editor.show_page_type_chooser();
			pages_editor.open();
		});
	};
	
	var setup_preview_thumbnailing = function() {
		$('#page-previews li.page a.choose-thumbnail').click(function() {
			var page_number = $(this).parent().attr('page-number');
			var $form_input = $('#story_thumbnail_page');
			$form_input.val(page_number);
			$(this).parents('ul:eq(0)').find('a.choose-thumbnail').removeClass('chosen');
			$(this).addClass('chosen');
			return false;
		});
	};
	
	var setup_grid_editing = function() {
		$('#page-editor .grid .cells a').live('click', function() {
			var $parent = $(this).parent();
			$parent.hide();
			$parent.siblings().show();
		});
	};
	
	this.setup_style_editor = function(current_page) {
		var $color_picker = current_page.find('.color-picker');
		_.each($color_picker, function(picker) {
			var $picker = $(picker);
			var color = $picker.css('backgroundColor');
			var style_affected = $picker.attr('affected-style');
			console.log(style_affected);
			var $elements_affected = $picker.parents('.page:eq(0)').find('.color-affected');
			var $form_field = $picker.siblings('input');
			$picker.ColorPicker({
				color: color,
				onChange: function (hsb, hex, rgb) {
					$picker.css('backgroundColor', '#' + hex);
					$elements_affected.css(style_affected, '#' + hex);
					$form_field.val(hex);
				}
			});
		});
		
	}
	
	var initialize_first_page = function() {
		var $page1 = $('#page_1');
		// is there data in page 1?
		if (! $page1.html().trim() == "") {
			$page1.show();
			$page1.click(pages_editor.hide_page_type_chooser);
			pages_editor.hide_page_type_chooser();
		}
	};
	
	// PAGE THEME CHOOSING
	
	this.choose_page_theme = function(page_type) {
		var $current_page = $('#page_' + pages_editor.page);
		$.get('/stories/render_page_theme?theme=' + page_type + '&page=' + pages_editor.page, function(result) {
			$current_page.html(result);
			$current_page.find('input[placeholder],textarea[placeholder]').placeholder();
			pages_editor.setup_style_editor($current_page);
			$current_page.fadeIn();
			$current_page.click(pages_editor.hide_page_type_chooser);
			pages_editor.hide_page_type_chooser();
			pages_editor.set_preview_type(page_type);
		});
	};
	
	// VISUAL CHANGES
	
	this.open = function() {
		$('body').addClass('fullscreen');
		$('#page-editor').removeClass('hidden').siblings().hide();
		$('#error-explanation').hide();
		return false;
	};
	
	this.close = function() {
		$('body').removeClass('fullscreen');
		$('#page-editor').addClass('hidden').siblings().show();
		$('#error-explanation').show();
		return false;
	};
	
	this.hide_page_type_chooser = function() {
		if (!pages_editor.page_chooser_open) {
			return;
		} else {
			$('#page-type-chooser, #pages').animate({ top: '-160'}, 500, pages_editor.show_layout_chooser_button);
			pages_editor.page_chooser_open = false;
		}
	};
	
	this.show_page_type_chooser = function() {
		if (pages_editor.page_chooser_open) {
			return;
		} else {
			$('#page-type-chooser, #pages').animate({ top: '0'}, 500, pages_editor.hide_layout_chooser_button);
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
	
	this.goto_page = function(page_number) {
		page_number = parseInt(page_number);
		if (page_number >= 1 && page_number <= 10) {
			var $page = $('#page_' + page_number);
			$page.siblings('.page').hide();
			$page.show();
			pages_editor.set_current_page(page_number);
		}
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
		$('#page_info .current').text(new_page);
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
		$('#previous-page').hide();
	};
	
	this.hide_next_page_button = function() {
		$('#next-page').hide();
	};
	
	this.set_preview_type = function(type) {
		var $preview_page = $('#preview_' + pages_editor.page);
		$preview_page.removeClass(pages_editor.page_type_css_classes);
		$preview_page.addClass(type + ' chosen');
	};
	
}

function clicking_a_child_topic_clicks_the_parent() {
	$('li.topics .children input').click(function() {
		if ($(this).is(':checked')) {
			var $parent_checkbox = $(this).parents('li.topic:eq(1)').children('input');
			if (! $parent_checkbox.is(':checked')) {
				$parent_checkbox.click();
			}
		}
	});
}

$(document).ready(function() {
	pages_editor = new story_page_editor();
	pages_editor.initialize();
	
	clicking_a_child_topic_clicks_the_parent();
});