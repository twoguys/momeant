var pages_editor;
var story_page_editor = function() {
	
	this.story_id = null;
	this.page = 1;
	this.page_chooser_open = false;
	this.page_chooser_mode = 'change';
	this.page_type_css_classes = 'title full_image pullquote video split';
	this.total_pages = 0;
	
	this.initialize = function() {
		this.story_id = $('#story_id').val();

		$('#open-page-editor-button').click(function() {
			pages_editor.goto_page(pages_editor.page);
			pages_editor.open();
			if ($(this).hasClass('launch')) {
				//pages_editor.page_chooser_mode = 'change';
				pages_editor.show_page_type_chooser();
			}
			return false;
		});
		$('#close-page-editor-button').click(pages_editor.close);
		$('#next-page').click(pages_editor.goto_next_page);
		$('#previous-page').click(pages_editor.goto_previous_page);
		$('#pane .expander-tab').click(pages_editor.open_or_close_pane);

		setup_page_type_chooser();
		setup_creation_or_external_choosing();
		setup_title_mirroring();
		setup_gallery_creation();
		this.setup_preview_thumbnail_switching($('#page-previews li.page a.choose-thumbnail'));
		this.setup_preview_clicking($('#page-previews li.page'));
		setup_page_adding();
		$('#editor-header a.delete').click(pages_editor.delete_current_page);
		setup_launch_when_no_pages();
		setup_sharing_toggles();
		$('#content-rights-link').fancybox();

		this.total_pages = $('ul#pages').children().length;
	};
	
	// SETUP
	
	var setup_page_type_chooser = function() {
		$('#page-type-chooser .body li').click(function() {
			var page_type = $(this).attr('page-type');
			$(this).addClass('loading');
			pages_editor.choose_page_theme(page_type);
		});
		$('#page-type-chooser .dark, #page-type-chooser .close').click(pages_editor.hide_page_type_chooser);
	};
	
	var setup_creation_or_external_choosing = function() {
		var change_to_external = function() {
			if ($('#creator').hasClass('selected')) {
				$('#external').addClass('selected');
				$('#creator').removeClass('selected');
				$('#open-page-editor-button').addClass('launch');
				$.post('/stories/' + pages_editor.story_id + '/change_to_external');
				var link_value = $('#story_external_link').val();
				if (link_value != "http://" && link_value != "") {
					$.ajax({
						type: 'PUT',
						url: '/stories/' + pages_editor.story_id + '/autosave',
						data: {'story[external_link]': link_value}
					});
				}
			}
		};
		$('#external').click(change_to_external);
		
		var change_to_creator = function() {
			if ($('#external').hasClass('selected')) {
				$('#external').removeClass('selected');
				$('#creator').addClass('selected');
				$.post('/stories/' + pages_editor.story_id + '/change_to_creator');
				$('ul#pages li.page, #page-editor ul.pages li.pane-insides').remove();
				pages_editor.page_chooser_mode = 'add';
				pages_editor.total_pages = 0;
			}
		}
		$('#creator').click(change_to_creator);
		$('#open-page-editor-button').click(change_to_creator);
	};
	
	var setup_gallery_creation = function() {
		$('#gallery-creator .overlay').click(function() {
			$('#gallery-creator').hide();
		});
		$('#story_gallery_id').change(function() {
			var $select = $(this);
			// creating a new gallery
			if ($select.val() == '-1') {
				$('#gallery-creator').show();
				$('#cancel-gallery-creation').click(function() {
					$('#gallery-creator').hide();
				});
				$('#gallery-form').submit(function(event) {
					event.preventDefault(); 

					var $form = $(this);
					var name = $form.find('#gallery_name').val();
					var description = $form.find("#gallery_description").val();
					var url = $form.attr('action');

					$('#gallery-creator').addClass('loading');
					$.post(url, { "gallery[name]":name, "gallery[description]":description }, function(data) {
						if (data.success) {
							$select.find('option:eq(0)').after('<option value="' + data.id + '">' + name + '</option>');
							$select.find('option:eq(1)').attr('selected','selected');
							auto_saver.update_gallery(data.id);
							$('#gallery-creator').removeClass('loading').hide();
						}
					});
				});
			}
		});
	};
	
	var setup_title_mirroring = function() {
		$('#story_title').keyup(function() {
			var $thumbnail_title = $('#thumbnail-preview .title');
			var title = $(this).val();
			if (title.length > 0) {
				$thumbnail_title.text(title);
			} else {
				$thumbnail_title.text("Title");
			}
		});
	};
	
	this.setup_preview_clicking = function($elements) {
		$elements.click(function() {
			var page_number = $(this).attr('page-number');
			pages_editor.goto_page(page_number);
			pages_editor.open();
		});
	};
	
	this.setup_preview_thumbnail_switching = function($elements) {
		$elements.click(function() {
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
		
	var setup_page_adding = function() {
		$('#editor-header a.add').click(function() {
			pages_editor.page_chooser_mode = 'add';
			pages_editor.show_page_type_chooser();
			return false;
		});
	};
	
	var setup_launch_when_no_pages = function() {
		$('#page-previews li.page.launch').click(function() {
			pages_editor.page_chooser_mode = 'add';
			pages_editor.show_page_type_chooser();
			return false;
		});
	};
	
	var setup_sharing_toggles = function() {
		$('#share.step input').live('click', function() {
		  var $checkbox = $(this);
		  var service = $checkbox.attr('name');
		  if ($checkbox.is(':checked')) {
		    $('#share_' + service).val('yes');
		  } else {
		    $('#share_' + service).val('');
		  }
		});
	};
	
	// VISUAL CHANGES
	
	this.open = function() {
		$('body').addClass('fullscreen');
		$('#page-editor').removeClass('hidden').siblings().hide();
		
		if (!$.browser.webkit && !$.browser.mozilla) {
		  alert('The Momeant fullscreen editor uses new web standards and may not behave properly in your browser. We recommend using a new version of Firefox, Chrome, or Safari.');
		}
		
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
	
	this.open_pane = function() {
		$('#pane').removeClass('closed');
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
	
	this.update_slider_nav = function() {
		$('#editor-header .current-slide span').text(pages_editor.page);
		if (pages_editor.page == 1)
			pages_editor.hide_previous_page_button();
		else
			pages_editor.show_previous_page_button();
		if (pages_editor.page < pages_editor.total_pages) {
			pages_editor.show_next_page_button();
			$('#editor-header .actions a.add').hide();
		} else {
			pages_editor.hide_next_page_button();
			$('#editor-header .actions a.add').show();
		}
		if (pages_editor.total_pages == 1)
			$('#editor-header .actions a.delete').hide();
		else
			$('#editor-header .actions a.delete').show();
	};
	
	// BROWSING
	
	this.goto_next_page = function() {
		if (pages_editor.page == pages_editor.total_pages) { return false; }
		pages_editor.goto_page(pages_editor.page + 1);
		return false;
	};
	
	this.goto_previous_page = function() {
		if (pages_editor.page == 1) { return false; }
		pages_editor.goto_page(pages_editor.page - 1);
		return false;
	};
	
	this.goto_page = function(page_number_string, page_number_already_updated) {
		var page_number = parseInt(page_number_string);
		if (page_number < 1 || page_number > pages_editor.total_pages) { return false; }
		
		var $page = $('ul#pages #page_' + page_number);
		$page.siblings('.page').hide();
		$page.show();
		pages_editor.set_current_page(page_number, page_number_already_updated);
	};
	
	this.set_current_page = function(new_page, page_number_already_updated) {
		if (page_number_already_updated) {
			var $old_pane = $('#pane ul.pages li#page_' + (pages_editor.page - 1));
		} else {
			var $old_pane = $('#pane ul.pages li#page_' + pages_editor.page);
		}
		var $new_pane = $('#pane ul.pages li#page_' + new_page);
		$old_pane.hide();
		$new_pane.show();

		pages_editor.page = new_page;
		
		pages_editor.update_slider_nav();
	};
	
	// EDITING
	
	this.change_page_type = function() {
		pages_editor.page_chooser_mode = 'change';
		pages_editor.show_page_type_chooser();
		return false;
	};
	
	this.choose_page_theme = function(page_type) {
		if (pages_editor.page_chooser_mode == 'add') {
			pages_editor.add_new_page(page_type);
		}
		var $current_page = $('#pane #page_' + pages_editor.page);
		// update the edit pane
		$.get('/stories/render_page_form?theme=' + page_type + '&page=' + pages_editor.page, function(result) {
			$current_page.html(result);
			pages_editor.hide_page_type_chooser();
			if (pages_editor.page_chooser_mode == 'add') {
				pages_editor.goto_page(pages_editor.page, true);
				$('#open-page-editor-button').removeClass('launch');
			}
			
			$('#page-type-chooser li[page-type="' + page_type + '"]').removeClass('loading');
			pages_editor.set_preview_type(page_type);
			// open the pane if it's closed
			pages_editor.open_pane();
			
			auto_saver.create_or_change_page($current_page, page_type, pages_editor.page, pages_editor.page_chooser_mode == 'add');
		});
		// update the full-size and thumbnail previews as well
		var $full_page = $('ul#pages li#page_' + pages_editor.page);
		var $thumbnail = $('#page-previews li#preview_' + pages_editor.page + ' .inner');
		var url = '/stories/render_page_theme?theme=' + page_type + '&story_id=' + pages_editor.story_id + '&number=' + pages_editor.page;
		$.get(url, function(result) {
			$full_page.html(result);
			$thumbnail.html(result);
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
	
	this.add_new_page = function(type) {
		pages_editor.total_pages += 1;
		pages_editor.page = pages_editor.total_pages;
		var new_edit_pane_html = '<li id="page_' + pages_editor.page + '" class="pane-insides hidden" ' + 'page-type="' + type + '" page-id=""></li>';
		$('#pane ul.pages').append(new_edit_pane_html);
		var new_fullscreen_html = '<li id="page_' + pages_editor.page + '" class="page ' + type + '" page-type="' + type + '" page-id=""></li>';
		$('ul#pages').append(new_fullscreen_html);
		var new_preview_html = '<li id="preview_' + pages_editor.page + '" class="page ' + type + '" page-number="' +
			pages_editor.page + '">' + '<div class="inner"></div><a class="choose-thumbnail" href="#">set thumbnail</a></li>';
		$('#page-previews ul.previews').append(new_preview_html);
		pages_editor.setup_preview_thumbnail_switching($('#page-previews li#preview_' + pages_editor.page + ' a.choose-thumbnail'));
		pages_editor.setup_preview_clicking($('#page-previews li#preview_' + pages_editor.page));
		var $current_page = $('#pane #page_' + pages_editor.page);
	};
	
	this.delete_current_page = function() {
		if (pages_editor.total_pages < 2) { return false; }
		if (!confirm('Are you sure you want to remove Slide ' + pages_editor.page + '?')) { return false; }
		
		// grab the stuff we're about to delete
		var current_page_num = pages_editor.page;
		var $current_pane = $('#pane ul.pages li#page_' + current_page_num);
		var $current_preview = $('ul#pages li#page_' + current_page_num);
		var $current_thumbnail = $('#page-previews ul.previews li#preview_' + current_page_num);

		// fade out the current page to provide the right UX
		$current_pane.fadeOut(500, function() {
			
			pages_editor.total_pages -= 1;

			// if not deleting page 1, go ahead and move to the next lowest page (otherwise we'll do it in a bit)
			if (pages_editor.page > 1) {
				pages_editor.goto_page(pages_editor.page - 1);
			}

			// remove the deleted page stuff
			$current_pane.remove();
			$current_preview.remove();
			$current_thumbnail.remove();
			
			// update the DOM page ids to use the new page numbers
			_.each($("ul#pages li.page, #page-previews li.page, #pane ul.pages li.pane-insides"), function(element) {
				var $element = $(element);
				var id = $element.attr('id');
				var first_part = id.substring(0, id.indexOf('_') + 1);
				var page_num = parseInt(id.substring(id.indexOf('_') + 1, id.length));
				if (page_num > current_page_num) {
					var new_num = page_num - 1;
					$element.attr('id', first_part + new_num);
				}
			});
			
			// if deleting page 1, now that we've updated the DOM, let's refresh everything
			if (pages_editor.page == 1) {
				pages_editor.goto_page(1);
			}

			// let's tell the server we're deleting this page
			$.ajax({
				type: 'DELETE',
				url: '/stories/' + pages_editor.story_id + '/pages/' + $current_pane.attr('page-id'),
				success: function(data) {
				}
			});
		});
		
		return false;
	};
	
	this.update_metadata = function(metadata) {
		if (!metadata) { return; }
		
		if (metadata.title != undefined) {
			$('#story_title').val(metadata.title);
			$('#thumbnail-preview .title').text(metadata.title);
		}
		if (metadata.description != undefined)
			$('#story_synopsis').val(metadata.description);
		if (metadata.image != undefined) {
			$('#thumbnail-preview .thumbnail').css('background-image', 'url(' + metadata.image + ')');
			$('#thumbnail-preview .note').show();
		}
	};
	
}

var auto_saver;
var story_auto_saver = function() {
	this.metadata_spinner_count = 0;
	this.metadata_has_saved = false;
	this.pages_spinner_count = 0;
	this.observe_delay = 1;
	
	this.initialize = function() {
		this.monitor_thumbnail_choosing();
		this.monitor_details_typing();
		this.monitor_topic_clicking();
		this.monitor_existing_pages();
		this.monitor_gallery_choosing();
		this.monitor_own_this_content_checkbox();
	};
	
	this.monitor_thumbnail_choosing = function() {		
		var $uploader = $('#thumbnail .file-uploader');
		var $preview = $('#thumbnail-preview .thumbnail')
		var $loader = $uploader.find('.loader');
		var $file_input = $uploader.find('input[type="file"]');
		var url = '/stories/' + pages_editor.story_id + '/update_thumbnail';

		var uploader = $file_input.html5_upload({
			url: url,
			autostart: true,
			sendBoundary: window.FormData || $.browser.mozilla,
			fieldName: 'image',
			onStart: function() {
				$loader.show().siblings().hide();
				return true;
			},
			onFinishOne: function(event, response, name, number, total) {
				json = $.parseJSON(response);
				$preview.css('background','#fff url(' + json.thumbnail + ')');
  			$('#thumbnail-preview .note').show();
				$loader.hide().siblings().show();
			}
		});
		var $upload_button = $uploader.find('a.upload');
		$upload_button.click(function() {
			if ($file_input.val() != "")
				uploader.trigger('html5_upload.start');
			return false;
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
							if (attribute_to_update == 'external_link') {
								pages_editor.update_metadata(data.metadata);
							}
						} else {
							log('error when updating page with: ' + value);
						}
					}
				});
			});
		});
	};
		
	this.monitor_gallery_choosing = function() {
		$('#story_gallery_id').change(function() {
			var gallery_id = parseInt($(this).val());
			auto_saver.update_gallery(gallery_id);
		});
	};
	
	this.update_gallery = function(gallery_id) {
		// make sure they're choosing an existing gallery
		if (gallery_id >= 0) {
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/autosave',
				data: {
					'story[gallery_id]': gallery_id
				},
				success: function(data) {
					auto_saver.hide_metadata_spinner();
				}
			});
		}
	}
	
	this.show_metadata_spinner = function() {
		auto_saver.metadata_spinner_count += 1;
		if (auto_saver.metadata_spinner_count == 1) {
			$('#story-spinner').animate({top:'42px'}, 200);
		}
	};
	
	this.hide_metadata_spinner = function() {
		auto_saver.metadata_spinner_count -= 1;
		if (auto_saver.metadata_spinner_count == 0) {
			$('#story-spinner').animate({top:0}, 200);
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
	
	this.monitor_page = function($page, id, type, number, new_page) {
		$page.find('a.change').click(pages_editor.change_page_type);
		$page.find('a.save').click(pages_editor.open_or_close_pane);
		auto_saver.monitor_page_typing($page, id, type, number);
		auto_saver.handle_image_uploading($page, id, type, number);
		auto_saver.monitor_bgcolor_updates($page, id, type, number);
		auto_saver.monitor_mirroring($page, id, type, number);
		auto_saver.monitor_placement($page, id, type, number);
		auto_saver.monitor_image_placement($page, id, type, number);
		auto_saver.monitor_thumbnail_switching($page, id, type, number);
		auto_saver.handle_video_embedding($page, id, type, number);
		auto_saver.handle_split_configuration($page, id, type, number);
		auto_saver.handle_grid_configuration($page, id, type, number);
		auto_saver.setup_rich_text_editing($page, id, type, number);
		auto_saver.handle_tip_showing($page, id, type, number);
		auto_saver.handle_text_style_chooser($page, id, type, number);
		auto_saver.handle_external_iframing($page, id, type, number);
	};
	
	this.create_or_change_page = function($page, type, number, new_page) {
		$.post('/stories/' + pages_editor.story_id + '/pages',
			{ type: type, number: number },
			function(data) {
				if (data.result == "success") {
					if (new_page)
						$page.attr('page-id', data.id);
					auto_saver.monitor_page($page, data.id, type, number, new_page);
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
				auto_saver.monitor_page($page, page_id, page_type, number);
			}
		});
	};
	
	this.monitor_mirroring = function($page, page_id, type, number) {
		_.each($page.find('.mirrored'), function(input) {
			var $from = $(input);
			var $to = $('ul#pages li#page_' + number + ' .' + $from.attr('mirror-to') + ', #page-previews li#preview_' + number + ' .' + $from.attr('mirror-to'));
			$from.keyup(function() {
				if (type == 'full_image') {
					// if caption isn't there and we have text, create it
					if ($from.val() != '' && $('ul#pages li#page_' + number + ' .caption').length == 0) {
						$('ul#pages li#page_' + number + ' .inner').append('<div class="caption placeable"></div>');
						$to = $('ul#pages li#page_' + number + ' .caption');
					// if caption is there but the text is empty, remove it
					} else if ($from.val() == '' && $to.length != 0) {
						$to.remove();
					}
				}
				$to.text($from.val());
			});
		});
	};
	
	this.monitor_placement = function($page, page_id, type, number) {
		_.each($page.find('.placement'), function(placement) {
			$(placement).find('ul.picker li').click(function() {
				var $position = $(this);
				var position = $position.attr('position');
				var data = {placement:position, type:type, number:number};
				var side = $position.attr('side');
				if (side)
					data['side'] = side;
				$position.addClass('chosen').siblings().removeClass('chosen');
				$('ul#pages li#page_' + number + ' .placeable').removeClass('top-left top-right bottom-left bottom-right').addClass(position);
				auto_saver.show_pages_spinner();
				$.ajax({
					type: 'PUT',
					url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
					data: data,
					success: function(data) {
						auto_saver.hide_pages_spinner();
					}
				});
			});
		});
	};
	
	this.monitor_image_placement = function($page, page_id, type, number) {
		$page.find('.image_placement').change(function() {
			var $select = $(this);
			var placement = $select.val();
			var position = $select.attr('position') || '';
			var side = $select.attr('side') || '';
			if (type == 'full_image') {
				$('ul#pages li#page_' + number + ' .inner').removeClass('fill-screen fit-to-screen original').addClass(placement);
			} else if (type == 'grid') {
				log('ul#pages li#page_' + number + ' cell_' + position + ' .side.' + side);
				$('ul#pages li#page_' + number + ' .cell_' + position + ' .side.' + side).removeClass('fill-screen fit-to-screen original').addClass(placement);
			} else if (type == 'split'){
				$('ul#pages li#page_' + number + ' .image' + position + ' .inner').removeClass('fill-screen fit-to-screen original').addClass(placement);
			} else {
				$('ul#pages li#page_' + number + ' .image' + position).removeClass('fill-screen fit-to-screen original').addClass(placement);
			}
			var data = {image_placement:placement, type:type, number:number};
			if (position)
				data['position'] = position;
			if (side)
				data['side'] = side;
			auto_saver.show_pages_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
				data: data,
				success: function(data) {
					auto_saver.hide_pages_spinner();
				}
			});
		});
	};
	
	this.monitor_thumbnail_switching = function($page, page_id, type, number) {
		$('#page-previews li#preview_' + number + ' a.choose-thumbnail').click(function() {
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/autosave',
				data: {
					'story[thumbnail_page]': number
				},
				success: function(data) {
					auto_saver.hide_metadata_spinner();
					if (data.result == "success") {
						log('successfully updated thumbnail to: ' + number);
					} else {
						log('error when updating thumbnail to: ' + number);
					}
				}
			});
		});
	};
	
	this.monitor_own_this_content_checkbox = function() {
		$('#i_own_this').change(function() {
			var $check = $(this);
			var checked = $check.is(':checked') ? '1' : '0';
			
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/autosave',
				data: {
					'story[i_own_this]': checked
				},
				success: function(data) {
					auto_saver.hide_metadata_spinner();
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
	
	this.save_text = function($element, page_id, type, number, optional_text) {
		var data = {};
		data['type'] = type;
		data['number'] = number;
		if (optional_text) {
			data['text'] = optional_text;
		} else {
			data['text'] = $element.val();
		}
		var position = $element.attr('position');
		if (position) {
			data['position'] = position;
		}
		var side = $element.attr('side');
		if (side) {
			data['side'] = side;
		}
		auto_saver.show_pages_spinner();
		$.ajax({
		  type: 'PUT',
		  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
		  data: data,
		  success: function(data) {
				if (data.result == "success") {
					auto_saver.hide_pages_spinner(true);
				} else {
					log('error when updating page ' + page_id);
				}
			}
		});
	};
	
	this.monitor_page_typing = function($page, page_id, type, number) {
		$page.find('.monitor-typing').observe_field(auto_saver.observe_delay, function(value, object) {
			auto_saver.save_text($(object), page_id, type, number);
		});
	};
	
	this.monitor_bgcolor_updates = function($page, page_id, type, number) {
		$page.find('.bgcolor').each(function() {
			$(this).change(function() {
				var $element = $(this);
				var color = $element.val();
				var position = $element.attr('position');
				var position_selector = '';
				var data = { type: type, number: number, background_color: color};
				if (position) {
					position_selector += '.' + position;
					data['position'] = position;
				}
				$('ul#pages #page_' + number + ' .bg-affected' + position_selector + ', #page-previews #preview_' + number + ' .bg-affected' + position_selector).css('background-color', color);
				auto_saver.show_pages_spinner();
				$.ajax({
				  type: 'PUT',
				  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
				  data: data,
				  success: function(data) {
						if (data.result == "success") {
							log('successfully updated page ' + page_id + ' with: ' + color);
							auto_saver.hide_pages_spinner(true);
						} else {
							log('error when updating page ' + page_id);
						}
					}
				});
			});
			$(this).colorPicker();
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
			
			if (type == 'grid') {
				var position = $file_input.attr('position');
				if (position)
					url += '?position=' + position;
				var side = $file_input.attr('side');
				if (position && side)
					url += '&side=' + side;
			}
			
			if (type == 'split') {
				var $parent = $uploader.parents('.input:eq(0)');
				if ($parent.hasClass('image1'))
					url += '?position=1'
				else
					url += '?position=2'
			}
				
			var page_number = number;
			var uploader = $file_input.html5_upload({
				url: url,
				autostart: false,
				sendBoundary: window.FormData || $.browser.mozilla,
				fieldName: 'image',
				onStart: function() {
					$loader.show().siblings().hide();
					return true;
				},
				onFinishOne: function(event, response, name, number, total) {
					json = $.parseJSON(response);
										
					if (type == 'full_image') {
						// Paperclip saves the image with the same URL on Amazon S3 so the browser doesn't update the image
						// By removing the node and re-adding it the new image shows up
						$('ul#pages #page_' + page_number + ' .image').remove();
						$('ul#pages #page_' + page_number + ' .inner').append('<div class="image" style="background-image: url(' + json.full + ');"></div>');
						
						var $thumbnail = $('#preview_' + page_number);
						if ($thumbnail.find('.image').length > 0) {
							$('#preview_' + page_number + ' .image').css('background-image', 'url(' + json.thumbnail + ')');
						} else {
							$thumbnail.prepend('<div class="inner"><div class="image" style="background-image: url(' + json.thumbnail + ');"></div></div>');
						}

					} else if (type == 'split') {
						if ($parent.hasClass('image1'))
							var class_of_element_to_replace = 'image1';
						else
							var class_of_element_to_replace = 'image2';
						$('ul#pages #page_' + page_number + ' .' + class_of_element_to_replace + ' .inner').remove();
						$('ul#pages #page_' + page_number + ' .' + class_of_element_to_replace).append('<div class="inner" style="background-image: url(' + json.full + ');"></div>');

					} else if (type == 'grid') {
						var $cell = $('ul#pages #page_' + page_number + ' ul.cells li[position="' + position + '"] .' + side);
						$cell.find('.image').remove();
						$cell.append('<div class="image" style="background-image: url(' + json.full + ');"></div>');
					}
					
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
	
	this.handle_video_embedding = function($page, page_id, type, number) {
		if (type != 'video') { return false; }
		
		$page.find('a.save').click(function() {
			var $from = $page.find('input.monitor-typing');
			var $to = $('ul#pages li#page_' + number + ' iframe');
			var $parent = $to.parent();
			// update the video URL, remove it and re-add it to make the browser refresh it
			var $iframe = $to.attr('src', 'http://player.vimeo.com/video/' + $from.val()).remove();
			$parent.append($iframe);
		});
	};
	
	this.handle_split_configuration = function($page, page_id, type, number) {
		if (type != 'split') { return false; }
		
		var $preview = $('ul#pages li#page_' + number);
		var $thumbnail = $('#page-previews li#preview_' + number);
		$page.find('li.chooser ul li').click(function() {
			var $element = $(this);
			$element.addClass('selected').siblings().removeClass('selected');
			var layout = '';
			if ($element.hasClass('image-text')) {
				layout = 'image-text';
				$page.find('li.inputs li.image1, li.inputs li.text2').show();
				$page.find('li.inputs li.image2, li.inputs li.text1').hide();
				$preview.find('div.image1, div.text2').show();
				$preview.find('div.image2, div.text1').hide();
				$thumbnail.find('div.image1, div.text2').show();
				$thumbnail.find('div.image2, div.text1').hide();
			} else if ($element.hasClass('text-image')) {
					layout = 'text-image';
				$page.find('li.inputs li.image2, li.inputs li.text1').show();
				$page.find('li.inputs li.image1, li.inputs li.text2').hide();
				$preview.find('div.image2, div.text1').show();
				$preview.find('div.image1, div.text2').hide();
				$thumbnail.find('div.image2, div.text1').show();
				$thumbnail.find('div.image1, div.text2').hide();
			} else if ($element.hasClass('image-image')) {
				layout = 'image-image';
				$page.find('li.inputs li.image1, li.inputs li.image2').show();
				$page.find('li.inputs li.text1, li.inputs li.text2').hide();
				$preview.find('div.image1, div.image2').show();
				$preview.find('div.text1, div.text2').hide();
				$thumbnail.find('div.image1, div.image2').show();
				$thumbnail.find('div.text1, div.text2').hide();
			} else if ($element.hasClass('text-text')) {
				layout = 'text-text';
				$page.find('li.inputs li.text1, li.inputs li.text2').show();
				$page.find('li.inputs li.image1, li.inputs li.image2').hide();
				$preview.find('div.text1, div.text2').show();
				$preview.find('div.image1, div.image2').hide();
				$thumbnail.find('div.text1, div.text2').show();
				$thumbnail.find('div.image1, div.image2').hide();
			}
			auto_saver.show_pages_spinner();
			$.ajax({
			  type: 'PUT',
			  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
			  data: {
					type: type,
					number: number,
					layout: layout
				},
			  success: function(data) {
					if (data.result == "success") {
						log('successfully updated page ' + page_id + ' with layout: ' + layout);
						auto_saver.hide_pages_spinner(true);
					} else {
						log('error when updating page ' + page_id);
					}
				}
			});
		});
	};
	
	this.handle_grid_configuration = function($page, page_id, type, number) {
		if (type != 'grid') { return false; }
		
		var $preview = $('ul#pages li#page_' + number);
		var $thumbnail = $('#page-previews li#preview_' + number);
		$page.find('li.chooser ul li').click(function() {
			var $element = $(this);
			$element.addClass('selected').siblings().removeClass('selected');
			var position = $element.attr('position');
			$page.find('li.inputs li#cell_' + position).show().siblings().hide();
			return false;
		});
		$page.find('li.inputs h3 .types a').click(function() {
			var type = $(this).attr('type');
			$(this).parents('.side:eq(0)').find('.type.' + type).show().siblings('.type').hide();
			var position = $(this).attr('position');
			var side = $(this).attr('side');
			var $side = $('ul#pages li#page_' + number + ' li[position="' + position + '"] .' + side);
			if (type == 'image') {
				$side.find('.text').hide();
				$side.find('.image').show();
			} else if (type == 'text') {
				$side.find('.image').hide();
				$side.find('.text').show();
			}
			return false;
		});
	};
	
	this.setup_rich_text_editing = function($page, page_id, type, number) {
		$page.find('.rich-editable').each(function(index, element) {
			var $element = $(element);
			var tiny_mce_config = {
		    mode: 'exact',
				elements: $element.attr('id'),
				theme : "advanced",
		    theme_advanced_buttons1 : "forecolor,backcolor,bold,underline,italic,justifyleft,justifycenter,justifyright,justifyfull",
		    theme_advanced_buttons2 : "",
		    theme_advanced_buttons3 : "",
		    theme_advanced_toolbar_location : "top",
		    theme_advanced_toolbar_align : "left",
				theme_advanced_more_colors: false,
				
				plugins : "paste",
				paste_text_sticky : true,
				setup : function(ed) {
				    ed.onInit.add(function(ed) {
				      ed.pasteAsPlainText = true;
				    });
				  }
			};
			if (type == 'grid') {
				tiny_mce_config.theme_advanced_buttons1 = "forecolor,backcolor,bold,underline,italic";
				tiny_mce_config.theme_advanced_buttons2 = "justifyleft,justifycenter,justifyright,justifyfull";
			}
			tinyMCE.init(tiny_mce_config);
			
			if ($element.hasClass('mirrored')) {
				var $to = $('ul#pages li#page_' + number + ' .' + $element.attr('mirror-to') + ', #page-previews li#preview_' + number + ' .' + $element.attr('mirror-to'));
				var $save_button = $element.parents('.body:eq(0)').find('a.save');
				$save_button.click(function() {
					var editor = tinyMCE.get($element.attr('id'));
					if (editor.isDirty()) {
						auto_saver.save_text($element, page_id, type, number, editor.getContent());
						$to.html(editor.getContent());
						if (type == 'grid') {
							$to.removeClass('hidden').siblings().addClass('hidden');
						}
					}
				});
			}
		});
	};
	
	this.handle_external_iframing = function($page, page_id, type, number) {
		if (type != 'external') { return false; }
		
		$page.find('a.save').click(function() {
			var $from = $page.find('input[type="text"]');
			var $to = $('ul#pages li#page_' + number + ' iframe');
			var $parent = $to.parent();
			var url = $from.val();
			if (!(url.substring(0, 7) === "http://"))
				url = "http://" + url;
			// update the iframe src URL, remove it and re-add it to make the browser refresh it
			var $iframe = $to.attr('src', url).remove();
			$parent.append($iframe);
		});
	};
	
	this.handle_tip_showing = function($page, page_id, type, number) {
		$page.find('.tip-icon').click(function() {
			var $tips = $(this).siblings('.tips');
			if ($tips.css('display') == 'none')
				$tips.slideDown(300);
			else
				$tips.slideUp(300);
		});
	};
	
	this.handle_text_style_chooser = function($page, page_id, type, number) {
		var all_text_styles = 'blocky-title blocky-chunk blocky-paragraph deco-title deco-chunk deco-paragraph ' +
			'typewriter-title typewriter-chunk typewriter-paragraph cursive-title cursive-chunk cursive-paragraph ' +
			'big-word-sans-serif big-word-cursive';
		$page.find('.styles-wrapper .styles li').click(function() {
			var $style = $(this);
			$style.addClass('selected').siblings().removeClass('selected');
			var text_style = $style.attr('classname');
			$('ul#pages li#page_' + number + ' .text-style-affected').removeClass(all_text_styles).addClass(text_style);
			var data = { type: type, number: number, text_style: text_style};
			auto_saver.show_pages_spinner();
			$.ajax({
			  type: 'PUT',
			  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
			  data: data,
			  success: function(data) {
					if (data.result == "success") {
						auto_saver.hide_pages_spinner(true);
					} else {
						log('error when updating page ' + page_id);
					}
				}
			});
		});
		$page.find('.drop-capper .switch').click(function() {
			var $the_switch = $(this);
			if ($the_switch.hasClass('on')) {
				$(this).removeClass('on');
				$('ul#pages li#page_' + number + ' .text-style-affected').removeClass('drop-capped');
			} else {
				$(this).addClass('on');
				$('ul#pages li#page_' + number + ' .text-style-affected').addClass('drop-capped');
			}
			var data = { type: type, number: number, drop_capped: $the_switch.hasClass('on')};
			auto_saver.show_pages_spinner();
			$.ajax({
			  type: 'PUT',
			  url: '/stories/' + pages_editor.story_id + '/pages/' + page_id,
			  data: data,
			  success: function(data) {
					if (data.result == "success") {
						auto_saver.hide_pages_spinner(true);
					} else {
						log('error when updating page ' + page_id);
					}
				}
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