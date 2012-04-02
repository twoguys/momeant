window.MetaCreatorView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #type li a': 'choose_media_type'
	},
	
	initialize: function() {
	  this.observe_delay = 1;
	  
	  _.bindAll(this, 'monitor_typing');
	  
	  this.monitor_uploading($('#template .file-uploader'));
	  this.monitor_typing($('#template .monitor'));
	  this.monitor_select($('#story_category'));
  },
  
  choose_media_type: function(event) {
    var $link = $(event.currentTarget);
    
    $link.parent().addClass('selected').siblings().removeClass('selected');
    $('#story_media_type').val($link.text()).trigger('change');
    var $template = $('#type #template');
    $template.addClass('loading');
    
		auto_saver.show_metadata_spinner();
    $.ajax({
      url: '/stories/' + story_id + '/choose_media_type',
      type: 'PUT',
      data: { media_type: $link.text() },
      success: function(html) {
    		auto_saver.hide_metadata_spinner();
        $template.html(html).removeClass('loading');
        MetaCreator.monitor_uploading($template.find('.file-uploader'));
        MetaCreator.monitor_typing($template.find('.monitor'));
      }
    });
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
		max = parseInt(max);
		var current_characters = $input.val().length;
		var $characters_left = $('#characters-left .amount');
		$characters_left.text(max - current_characters);
		
		$input.keypress(function(event) {
      var current_characters = $input.val().length;
      if (current_characters == max) {
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