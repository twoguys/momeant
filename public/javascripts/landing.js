$(function() {
  
  var half_page_width = $('body').width() / 2;
  $('#faces').css('left', half_page_width + 'px')
	
	$('#faces .face a.avatar').click(function() {
    var $new_face = $(this).parent().parent();
    if ($new_face.hasClass('selected')) { return true; }

	  var $current_face = $('#faces .selected');
	  var new_index = $('#faces').children().index($new_face);
	  
    $current_face.find('.full').fadeOut(200);
    $current_face.find('.preview').fadeIn(200);
    $current_face.removeClass('selected');

    $new_face.find('.preview').fadeOut(200);
    $new_face.find('.full').fadeIn(200);
	  $new_face.addClass('selected');
    
    var existing_left = $('#faces').position().left;
    var new_left = half_page_width + (new_index * -105);
    $('#faces').animate({left: new_left + 'px'}, 200);
	  
	  return false;
	});
	
	$('#slogan-more-link').click(function() {
	  var $link = $(this);

    if ($link.hasClass('open')) {
      $('#slogan-more').fadeOut(200, function() {
        $('#slogan').animate({height: '-=150px'}, 200);
        $('#faces').animate({top:'-=150px'}, 200);
      });
    } else {
      $('#slogan').animate({height: '+=150px'}, 200, function() {
        $('#slogan-more').fadeIn(200);
      });
      $('#faces').animate({top:'+=150px'}, 200);
    }
	  
	  $link.toggleClass('open');
	  
	  return false;
	});
	
});