window.Cropper = Backbone.View.extend({
	
	el: $('#cropper'),
	
	events: {
		'submit #cropper-form': 'submit_crop'
	},
	
	initialize: function() {
		$('img#thumbnail-to-be-cropped').imgAreaSelect({
      handles: true,
      onSelectEnd: Cropper.update_cropped_thumbnail,
      zIndex: '9999',
      aspectRatio: '8:5'
    });
	},
	
	update_cropped_thumbnail: function(img, selection) {
	  log('updating crops');
	  $('#x1').val(selection.x1);
    $('#y1').val(selection.y1);
    $('#x2').val(selection.x2);
    $('#y2').val(selection.y2);
	},
	
	submit_crop: function() {
	  event.preventDefault();
    
    log(cropper_modal);
	}
});