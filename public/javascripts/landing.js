$(function() {
	
	$('#faces a').click(function() {
    var $new_face = $(this);
    if ($new_face.hasClass('selected')) { return false; }

	  var $current_face = $('#faces a.selected');
	  var $new_info = $('#info_for_' + $new_face.attr('info_id'));
	  var $current_info = $('.info.selected');
	  var new_index = $('#faces').children().index($new_face);
	  
	  $current_info.fadeOut(200);
	  $current_face.animate({opacity:0.5}, 200, function() {
	    $current_face.find('img').animate({width:'100px',height:'100px'}, 200, function() {
	      $new_face.animate({opacity:1}, 200, function() {
	        var new_left = new_index * -127 + 50;
	        $('#faces').animate({left: new_left + 'px'}, 200);
	        $new_face.find('img').animate({width:'200px',height:'200px'}, 200, function() {
	          $new_info.fadeIn(200);
        	  $current_face.removeClass('selected');
        	  $new_face.addClass('selected');
        	  $current_info.removeClass('selected');
        	  $new_info.addClass('selected');
      	  });
        });
	    });
	  });
	  
	  return false;
	});
	
});