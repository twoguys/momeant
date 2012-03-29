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
  },
  
  choose_media_type: function(event) {
    var $link = $(event.currentTarget);
    
    $link.parent().addClass('selected').siblings().removeClass('selected');
    $('#story_media_type').val($link.text()).trigger('change');
    var $template = $('#type #template');
    $template.addClass('loading');
    
    $.get('/stories/' + story_id + '/template?media_type=' + $link.text(), function(html) {
      $template.html(html).removeClass('loading');
      MetaCreator.monitor_uploading($template.find('.file-uploader'));
      MetaCreator.monitor_typing($template.find('.monitor'));
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
			auto_saver.show_metadata_spinner();
			$.ajax({
				type: 'PUT',
				url: '/stories/' + story_id + '/autosave',
				data: {'story[synopsis]': $input.val()},
				success: function() {
				  auto_saver.hide_metadata_spinner();
				}
			});
		});
	}
  
});

window.MetaCreator = new MetaCreatorView;