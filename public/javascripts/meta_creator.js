window.MetaCreatorView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #type li a': 'choose_media_type',
		'click #share': 'change_to_share',
		'click #create': 'change_to_create',
		'click #preview-image': 'change_preview_to_image',
		'click #preview-text': 'change_preview_to_text',
		'click #text-template a': 'choose_preview_text_template'
	},
	
	initialize: function() {
	  this.observe_delay = 1;
	  
	  _.bindAll(this, 'monitor_typing');
	  
	  this.monitor_uploading($('#preview-image-details .file-uploader'));
	  this.monitor_typing($('#story_template_text'));
	  this.monitor_select($('#story_category'));
  },
  
  change_to_share: function() {
		if ($('#share').hasClass('selected')) {
		  return false;
	  }
		$('#share, #share-details').addClass('selected');
		$('#create, #create-details').removeClass('selected');
		$('#open-page-editor-button').addClass('launch');
		auto_saver.show_metadata_spinner();
		$.post('/stories/' + pages_editor.story_id + '/change_to_external', function() {
		  auto_saver.hide_metadata_spinner();
		});
		var link_value = $('#story_external_link').val();
		if (link_value != "http://" && link_value != "") {
			$.ajax({
				type: 'PUT',
				url: '/stories/' + pages_editor.story_id + '/autosave',
				data: {'story[external_link]': link_value}
			});
		}
		return false;
	},
		
	change_to_create: function() {
		if ($('#create').hasClass('selected')) {
		  return false;
	  }
		$('#share, #share-details').removeClass('selected');
		$('#create, #create-details').addClass('selected');
		auto_saver.show_metadata_spinner();
		$.post('/stories/' + pages_editor.story_id + '/change_to_creator', function() {
		  auto_saver.hide_metadata_spinner();
		});
		$('ul#pages li.page, #page-editor ul.pages li.pane-insides').remove();
		pages_editor.page_chooser_mode = 'add';
		pages_editor.total_pages = 0;
		return false;
	},
  
  choose_media_type: function(event) {
    var $link = $(event.currentTarget);
    $link.parent().addClass('selected').siblings().removeClass('selected');
    MetaCreator.autosave('media_type', $link.text());
    return false;
  },

	change_preview_to_image: function() {
    if ($('#preview-image').hasClass('selected')) {
      return false;
    }
		$('#preview-image, #preview-image-details').addClass('selected');
		$('#preview-text, #preview-text-details').removeClass('selected');
		MetaCreator.autosave('preview_type', 'image');
		return false;
	},
	
	change_preview_to_text: function() {
	  if ($('#preview-text').hasClass('selected')) {
      return false;
    }
		$('#preview-text, #preview-text-details').addClass('selected');
		$('#preview-image, #preview-image-details').removeClass('selected');
		MetaCreator.autosave('preview_type', 'text');
		return false;
	},
	
	choose_preview_text_template: function(event) {
	  var $link = $(event.currentTarget);
	  $link.addClass('selected').siblings('a').removeClass('selected');
	  MetaCreator.autosave('template', $link.attr('data'));
	  return false;
	},
  
  monitor_uploading: function($uploader) {
    if ($uploader.length == 0) { return; }
    
		var $loader = $uploader.find('.loader');
		var $file_input = $uploader.find('input[type="file"]');
		var $preview = $uploader.siblings('.thumbnail');
		var url = '/stories/' + story_id + '/update_thumbnail';

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
				$loader.hide().siblings().show();
			}
		});
	},
	
	monitor_typing: function($input) {
	  if ($input.length == 0) { return; }
	  
	  $input.observe_field(this.observe_delay, function(value, object) {
			MetaCreator.autosave($input.attr('update'), $input.val());
		});
		
		var max = $input.attr('max');
		if (max == undefined) { return; }
		console.log(max);
		max = parseInt(max);
		var current_characters = $input.val().length;
		var $characters_left = $('#characters-left .amount');
		$characters_left.text(max - current_characters);
		
		$input.keypress(function(event) {
      var current_characters = $input.val().length;
      if (event.keyCode != 8 && current_characters == max) { // 8 = backspace
        event.preventDefault();
        $characters_left.text(0);
        return false;
      }
      $characters_left.text(max - current_characters);
		});
	},
	
	monitor_select: function($input) {
	  if ($input.length == 0) { return; }
	  
	  $input.change(function() {
	    MetaCreator.autosave($input.attr('update'), $input.val());
	  });
	},
	
	autosave: function(attribute, value) {
	  var data = {};
	  data['story[' + attribute + ']'] = value;
	  auto_saver.show_metadata_spinner();
		$.ajax({
			type: 'PUT',
			url: '/stories/' + story_id + '/autosave',
			data: data,
			success: function() {
			  auto_saver.hide_metadata_spinner();
			}
		});
	}
  
});

window.MetaCreator = new MetaCreatorView;