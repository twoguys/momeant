var pages_editor;
var story_page_editor = function() {
	
	this.story_id = null;
	this.page = 1;
	this.page_chooser_open = false;
	this.page_type_css_classes = 'title full_image pullquote video split';
	this.total_pages = 0;
	
	this.initialize = function() {
		this.story_id = $('#story_id').val();
		$('#open-page-editor-button').click(pages_editor.open);
		$('#close-page-editor-button').click(pages_editor.close);
		$('#next-page').click(pages_editor.goto_next_page);
		$('#previous-page').click(pages_editor.goto_previous_page);
		$('#pane .expander-tab').click(pages_editor.open_or_close_pane);
		$('.pane-insides a.save').click(pages_editor.open_or_close_pane);
		setup_page_type_chooser();
		setup_preview_clicking();
		setup_preview_thumbnailing();
		setup_grid_editing();
		//setup_key_bindings();
		this.total_pages = $('ul#pages li').length;
	};
	
	// SETUP
	
	var setup_page_type_chooser = function() {
		$('#page-type-chooser .body li').click(function() {
			var page_type = $(this).attr('page-type');
			$(this).addClass('loading');
			pages_editor.choose_page_theme(page_type);
		});
		$('.pane-insides a.change').click(pages_editor.show_page_type_chooser);
		$('#page-type-chooser .dark, #page-type-chooser .close').click(pages_editor.hide_page_type_chooser);
	};
	
	var setup_preview_clicking = function() {
		$('#page-previews li.page').click(function() {
			var page_number = $(this).attr('page-number');
			pages_editor.goto_page(page_number);
			var has_content = $(this).hasClass('has-content');
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
			$(this).parents('ul:eq(0)').find('li').removeClass('chosen-thumbnail');
			$(this).parent().addClass('chosen-thumbnail');
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
	
	var setup_key_bindings = function() {
		$(document).keyup(function(e) {
		  //if (e.keyCode == 27) { pages_editor.close(); }   							// esc
			if (e.keyCode == 39) { pages_editor.goto_next_page(); } 			// right arrow
			if (e.keyCode == 37) { pages_editor.goto_previous_page(); } 	// left arrow
		});
	};
	
	this.setup_style_editor = function(current_page) {
		$('.style-editor .insides').draggable();
		var $color_picker = current_page.find('.color-picker');
		_.each($color_picker, function(picker) {
			var $picker = $(picker);
			var color = $picker.css('backgroundColor');
			var style_affected = $picker.attr('affected-style');
			var elements_to_update_class = $picker.attr('update');
			var $elements_affected = $picker.parents('.page:eq(0)').find('.' + elements_to_update_class);
			var $form_field = $picker.siblings('input');
			$elements_affected.css(style_affected, color);
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
	
	// VISUAL CHANGES
	
	this.open = function() {
		$('body').addClass('fullscreen');
		$('#page-editor').removeClass('hidden').siblings().hide();
		$.scrollTo(43);
		return false;
	};
	
	this.close = function() {
		$('body').removeClass('fullscreen');
		$('#page-editor').addClass('hidden').siblings().show();
		return false;
	};
	
	this.hide_page_type_chooser = function() {
		if (pages_editor.page_chooser_open) {
			$('#page-type-chooser').hide();
			pages_editor.page_chooser_open = false;
		}
		return false;
	};
	
	this.show_page_type_chooser = function() {
		if (!pages_editor.page_chooser_open) {
			$('#page-type-chooser').show();
			pages_editor.page_chooser_open = true;
		}
		return false;
	};
	
	this.show_layout_chooser_button = function() {
		$('#page-type-chooser-button').show();
		$('#page-type-chooser-button').animate({ bottom: '-40'}, 500);
	};
	
	this.hide_layout_chooser_button = function() {
		$('#page-type-chooser-button').animate({ bottom: 0}, 500);
	};
	
	this.open_or_close_pane = function() {
		$('#pane').toggleClass('closed');
		return false;
	};

	this.show_previous_page_button = function() {
		$('#previous-page').show();
	};

	this.show_next_page_button = function() {
		$('#next-page').show();
	};

	this.hide_previous_page_button = function() {
		$('#previous-page').hide();
	};

	this.hide_next_page_button = function() {
		$('#next-page').hide();
	};
	
	// BROWSING
	
	this.goto_next_page = function() {
		if (pages_editor.page == 10) { return false; }
		pages_editor.change_page_by(1);
		return false;
	};
	
	this.goto_previous_page = function() {
		if (pages_editor.page == 1) { return false; }
		pages_editor.change_page_by(-1);
		return false;
	};

	this.change_page_by = function(difference) {
		var page = pages_editor.page;
		pages_editor.goto_page(page + difference);
	};
	
	this.goto_page = function(page_number_string) {
		var page_number = parseInt(page_number_string);
		if (page_number >= 1 && page_number <= 10) {
			var $page = $('ul#pages #page_' + page_number);
			//$page.click(pages_editor.hide_page_type_chooser);
			$page.siblings('.page').hide();
			$page.show();
			pages_editor.set_current_page(page_number);
		}
	};
	
	this.set_current_page = function(new_page) {
		var $old_pane = $('#pane ul.pages li#page_' + this.page);
		var $new_pane = $('#pane ul.pages li#page_' + new_page);
		$old_pane.hide();
		$new_pane.show();

		pages_editor.page = new_page;
		$('#editor-header .current-slide span').text(new_page);
		
		if (new_page == 1)
			pages_editor.hide_previous_page_button();
		else
			pages_editor.show_previous_page_button();
		if (new_page < pages_editor.total_pages) {
			pages_editor.show_next_page_button();
			$('#editor-header .actions a.add').hide();
		} else {
			pages_editor.hide_next_page_button();
			$('#editor-header .actions a.add').show();
		}	
	};
	
	// EDITING
	
	this.choose_page_theme = function(page_type) {
		// update the edit pane
		var $current_page = $('#page_' + pages_editor.page);
		$.get('/stories/render_page_form?theme=' + page_type + '&page=' + pages_editor.page, function(result) {
			$current_page.html(result);
			pages_editor.hide_page_type_chooser();
			$('#page-type-chooser li[page-type="' + page_type + '"]').removeClass('loading');
			$current_page.find('input[placeholder],textarea[placeholder]').placeholder();
			$current_page.find('a.change').click(pages_editor.show_page_type_chooser);
			pages_editor.set_preview_type(page_type);
			auto_saver.create_and_monitor_page($current_page, page_type, pages_editor.page);
		});
		// update the full-size preview behind the pane
		var $full_page = $('ul#pages li#page_' + pages_editor.page);
		$.get('/stories/render_page_theme?theme=' + page_type, function(result) {
			$full_page.html(result);
		});
	};
	
	this.set_preview_type = function(type) {
		var $preview_page = $('#preview_' + pages_editor.page);
		$preview_page.removeClass(pages_editor.page_type_css_classes);
		$preview_page.addClass(type + ' chosen');
		var $full_page = $('ul#pages li#page_' + pages_editor.page);
		$full_page.removeClass(pages_editor.page_type_css_classes);
		$full_page.addClass(type);
	};
	
	this.add_new_page = function() {
		
	};
	
}

var auto_saver;
var story_auto_saver = function() {
	this.metadata_spinner_count = 0;
	this.metadata_has_saved = false;
	this.pages_spinner_count = 0;
	this.observe_delay = 1;
	
	this.initialize = function() {
		this.monitor_details_typing();
		this.monitor_existing_pages();
		this.monitor_thumbnail_switching();
		this.monitor_topic_clicking();
	};
	
	this.show_metadata_spinner = function() {
		auto_saver.metadata_spinner_count += 1;
		if (auto_saver.metadata_spinner_count == 1) {
			$('#story-spinner').show();
			$('#story-saved').hide();
		}
		if (!auto_saver.metadata_has_saved) {
			auto_saver.metadata_has_saved = true;
			$('#story-saved').text('Saved');
		}
	};
	
	this.hide_metadata_spinner = function() {
		auto_saver.metadata_spinner_count -= 1;
		if (auto_saver.metadata_spinner_count == 0) {
			$('#story-spinner').hide();
			$('#story-saved').show();
		}
	};
	
	this.show_pages_spinner = function() {
		auto_saver.pages_spinner_count += 1;
		if (auto_saver.pages_spinner_count == 1) {
			$('#pane ul.pages li#page_' + pages_editor.page + ' .pane-insides .header .spinner').text('Saving...').removeClass('off').show();
		}
	};
	
	this.hide_pages_spinner = function() {
		auto_saver.pages_spinner_count -= 1;
		if (auto_saver.pages_spinner_count == 0) {
			$('#pane ul.pages li#page_' + pages_editor.page + ' .pane-insides .header .spinner').text('Saved').addClass('off');
		}
	};
	
	this.create_and_monitor_page = function($page, type, number) {
		$.post('/stories/' + pages_editor.story_id + '/pages',
			{
				type: type,
				number: number
			},
			function(data) {
				if (data.result == "success") {
					$page.find('.page-id').val(data.id);
					auto_saver.monitor_page_typing($page, data.id, type, number);
					auto_saver.handle_image_uploading($page, data.id, type, number);
					auto_saver.monitor_page_style_updates($page, data.id, type, number);
					auto_saver.monitor_mirroring($page, data.id, type, number);
					auto_saver.monitor_placement($page, data.id, type, number);
					auto_saver.monitor_image_placement($page, data.id, type, number);
				} else {
					log('error when creating a ' + type + ' page.');
				}
			}
		);
	};
	
	this.monitor_existing_pages = function() {
		$('#pane ul.pages li.pane-insides').each(function() {
			var $page = $(this);
			var page_id = $page.attr('page-id');
			if (page_id) {
				var page_type = $page.attr('page-type');
				var number = $page.attr('id').substring(5);
				auto_saver.monitor_page_typing($page, page_id, page_type, number);
				auto_saver.handle_image_uploading($page, page_id, page_type, number);
				auto_saver.monitor_page_style_updates($page, page_id, page_type, number);
				auto_saver.monitor_mirroring($page, page_id, page_type, number);
				auto_saver.monitor_placement($page, page_id, page_type, number);
				auto_saver.monitor_image_placement($page, page_id, page_type, number);
			}
		});
	};
	
	this.monitor_mirroring = function($page, page_id, type, number) {
		_.each($page.find('.mirrored'), function(input) {
			var $from = $(input);
			var $to = $('ul#pages li#page_' + number + ' .' + $from.attr('mirror-to'));
			$from.keyup(function() {
				$to.text($from.val());
			});
		});
	};
	
	this.monitor_placement = function($page, page_id, type, number) {
		_.each($page.find('.placement'), function(placement) {
			$(placement).find('ul.picker li').click(function() {
				var $position = $(this);
				var position = $position.attr('position');
				$position.addClass('chosen').siblings().removeClass('chosen');
				$('ul#pages li#page_' + number + ' .placeable').removeClass('top-left top-right bottom-left bottom-right').addClass(position);
				auto_saver.show_pages_spinner();
				$.ajax({
					type: 'PUT',
					url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
					data: {placement:position, type:type, number:number},
					success: function(data) {
						auto_saver.hide_pages_spinner();
					}
				});
			});
		});
	};
	
	this.monitor_image_placement = function($page, page_id, type, number) {
		$page.find('#image_placement').change(function() {
			var $select = $(this);
			var placement = $select.val();
			$('ul#pages li#page_' + number + ' .image').removeClass('fill-screen fit-to-screen original').addClass(placement);
			auto_saver.show_pages_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
				data: {image_placement:placement, type:type, number:number},
				success: function(data) {
					auto_saver.hide_pages_spinner();
				}
			});
		});
	};
	
	this.monitor_details_typing = function() {
		var $story_attributes_to_monitor = $('.monitor-story-typing');
		_.each($story_attributes_to_monitor, function(story_attribute) {
			var $story_attribute = $(story_attribute);
			$story_attribute.observe_field(auto_saver.observe_delay, function(value, object) {
				var attribute_to_update = $story_attribute.attr('update');
				var data = {};
				var value = $story_attribute.val();
				data['story[' + attribute_to_update + ']'] = value;
				auto_saver.show_metadata_spinner();
				$.ajax({
					type: 'PUT',
					url: '/stories/' + pages_editor.story_id + '/autosave',
					data: data,
					success: function(data) {
						auto_saver.hide_metadata_spinner();
						if (data.result == "success") {
							log('successfully updated story with: ' + value);
						} else {
							log('error when updating page with: ' + value);
						}
					}
				});
			});
		});
	};
	
	this.monitor_thumbnail_switching = function() {
		$('#page-previews a.choose-thumbnail').click(function() {
			var page_number = $(this).parent().attr('page-number');
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/autosave',
				data: {
					'story[thumbnail_page]': page_number
				},
				success: function(data) {
					auto_saver.hide_metadata_spinner();
					if (data.result == "success") {
						log('successfully updated thumbnail to: ' + page_number);
					} else {
						log('error when updating thumbnail to: ' + page_number);
					}
				}
			});
		});
	};
	
	this.monitor_topic_clicking = function() {
		$('li.topics li.topic input[type="checkbox"]').change(function() {
			var $checkbox = $(this);
			var topic_id = $checkbox.attr('topic-id')
			var url = 'add_topic_to';
			if (!$checkbox.is(':checked')) {
				url = 'remove_topic_from';
			}
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'POST',
				url: '/stories/' + pages_editor.story_id + '/' + url,
				data: {
					topic_id: topic_id
				},
				success: function(data) {
					auto_saver.hide_metadata_spinner();
					if (data.result == "success") {
						log('successful ' + url + ': ' + topic_id);
					} else {
						log(data.message);
					}
				}
			});
		});
	};
	
	this.monitor_page_typing = function($page, page_id, type, number) {
		$page.find('.monitor-typing').observe_field(auto_saver.observe_delay, function(value, object) {
			var value = $(object).val();
			var data = {};
			data['type'] = type;
			data['number'] = number;
			var cell = $(object).attr('cell');
			if (cell) {
				data['cells[' + cell + '][text]'] = value;
			} else {
				data['text'] = value;
			}
			auto_saver.show_pages_spinner();
			$.ajax({
			  type: 'PUT',
			  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
			  data: data,
			  success: function(data) {
					if (data.result == "success") {
						log('successfully updated page ' + page_id + ' with: ' + value);
						auto_saver.hide_pages_spinner(true);
					} else {
						log('error when updating page ' + page_id);
					}
				}
			});
		});
	};
	
	this.monitor_page_style_updates = function($page, page_id, type, number) {
		$page.find('.style-editor .widget input').each(function() {
			$(this).observe_field(auto_saver.observe_delay, function(value, object) {
				var style = $(object).attr('update');
				var data = {
					type: type,
					number: number,
				};
				data[style] = $(object).val();
				auto_saver.show_pages_spinner();
				$.ajax({
				  type: 'PUT',
				  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
				  data: data,
				  success: function(data) {
						if (data.result == "success") {
							log('successfully updated page ' + page_id + ' with: ' + value);
							auto_saver.hide_pages_spinner(true);
						} else {
							log('error when updating page ' + page_id);
						}
					}
				});
			});
		});
	};
	
	this.handle_image_uploading = function($page, page_id, type, number) {
		$page.find('.file-uploader').each(function() {
			var $uploader = $(this);
			var $loader = $uploader.find('.loader');
			var $file_input = $uploader.find('input[type="file"]');
			$file_input.change(function() {
				$file_input.siblings('.text').text($file_input.val());
			});
			var url = '/stories/' + pages_editor.story_id + '/pages/' + page_id + '/add_or_update_image';
			var grid_cell = $file_input.attr('cell');
			if (grid_cell)
				url += '?cell=' + grid_cell
			var page_number = number;
			var uploader = $file_input.html5_upload({
				url: url,
				autostart: false,
				sendBoundary: window.FormData || $.browser.mozilla,
				fieldName: 'image',
				onStart: function() {
					log('starting upload...');
					$loader.show().siblings().hide();
					return true;
				},
				onFinishOne: function(event, response, name, number, total) {
					json = $.parseJSON(response);
					
					// Paperclip saves the image with the same URL on Amazon S3 so the browser doesn't update the image
					// By removing the node and re-adding it the new image shows up
					$('ul#pages #page_' + (number + 1) + ' .image').remove();
					$('ul#pages #page_' + (number + 1) + ' .inner').append('<div class="image" style="background-image: url(' + json.full + ');"></div>');
					
					if (!grid_cell) {
						var $thumbnail = $('#preview_' + page_number);
						if ($thumbnail.find('.image').length > 0) {
							$('#preview_' + page_number + ' .image').css('background-image', 'url(' + json.thumbnail + ')');
						} else {
							$thumbnail.prepend('<div class="inner"><div class="image" style="background-image: url(' + json.thumbnail + ');"></div></div>');
						}
					}
					
					$uploader.find('.info').remove();
					$loader.hide().siblings().show();
				}
			});
			var $upload_button = $uploader.find('a.upload');
			$upload_button.click(function() {
				if ($file_input.val() != "")
					uploader.trigger('html5_upload.start');
				return false;
			});
		});
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
	
	auto_saver = new story_auto_saver();
	auto_saver.initialize();
	
	clicking_a_child_topic_clicks_the_parent();
});


// http://github.com/splendeo/jquery.observe_field
jQuery.fn.observe_field = function(frequency, callback) {

  return this.each(function(){
    var element = $(this);
    var prev = element.val();

    var chk = function() {
      var val = element.val();
      if(prev != val){
        prev = val;
        element.map(callback); // invokes the callback on the element
      }
    };
    chk();
    frequency = frequency * 1000; // translate to milliseconds
    var ti = setInterval(chk, frequency);
    // reset counter after user interaction
    element.bind('keyup', function() {
      ti && clearInterval(ti);
      ti = setInterval(chk, frequency);
    });
  });

};