window.CropperView = Backbone.View.extend({
	
	el: $('#cropper'),
	
	initialize: function() {
		$('img#thumbnail-to-be-cropped').imgAreaSelect({
      handles: true,
      onSelectEnd: Cropper.update_cropped_thumbnail,
      aspectRatio: '8:5'
    });
    $('#cropper-form').submit(Cropper.submit_crop); // Backbone event wasn't attaching for some reason
	},
	
	update_cropped_thumbnail: function(img, selection) {
	  $('#crop_x').val(selection.x1);
    $('#crop_y').val(selection.y1);
    $('#crop_width').val(selection.width);
    $('#crop_height').val(selection.height);
	},
	
	submit_crop: function(event) {
	  event.preventDefault();
    
    var x = $('#crop_x').val(),
        y = $('#crop_y').val(),
        width = $('#crop_width').val(),
        height = $('#crop_height').val();
    
    if (x == '' || y == '' || width == '' || height == '') {
      alert('Please select the part of the photo you want cropped by clicking and dragging your mouse.');
      return false;
    }
        
    var $preview = $('#thumbnail-preview .thumbnail').css('background','url(/images/spinner.gif) no-repeat 50% 40%');
    $('img#thumbnail-to-be-cropped').imgAreaSelect({remove:true});
	  $.fancybox.close();
    $.post(
      '/stories/' + pages_editor.story_id + '/crop',
      { 'story[crop_x]':x, 'story[crop_y]':y, 'story[crop_width]':width, 'story[crop_height]':height },
      function(result) {
        $preview.css('background','#fff url(' + result.thumbnail + ')');
		  }
		);
	}
});

window.Cropper = new CropperView;