$(function() {
  
  window.DiscoveryView = Backbone.View.extend({
		
		el: $('#main'),
		
		events: {
		  'click #goto-about': 'goto_about',
		  'click #goto-creators': 'goto_creators',
		  'click #goto-creators-secondary': 'goto_creators',
			'click #filter a': 'load_people'
		},
		
		initialize: function() {
			this.current_category = undefined;
			
			var height = $(window).height();
			$('#landing').css('height',height+'px').find('#message, #goto-creators, #goto-about').fadeIn(1000);
			
			_.bindAll(this, 'on_resize');
  	  $(window).resize(this.on_resize);
  	  
  	  $.scrollTo(0);
		},
		
		goto_about: function() {
		  var height = $(window).height();
		  $.scrollTo(height, 500, {easing:'easeOutQuart'});
		  return false;
		},
		
		goto_creators: function() {
		  $('#goto-creators-secondary').hide();
      $('#messaging').animate({'margin-left': '-50%'}, 500, 'easeOutQuart', function() {
		    $('#header').animate({top:0}, 300);
		    $.scrollTo(0, 300);
		    $('#about').hide();
		  });
		  return false;
		},
		
		load_people: function(event) {
		  var $link = $(event.currentTarget);
		  if ($link.hasClass('selected')) {
		    Discovery.current_category = '';
		    $link.removeClass('selected');
		  } else {
		    $link.addClass('selected').parent().siblings().find('a').removeClass('selected');
        Discovery.current_category = $link.text();
		  }
      
      $('#choose-a-category:visible').fadeOut(200);
      var $people = $('#people');
      if (!$people.is(':visible')) { $people.show(); }
      $people.addClass('loading');
      $.get('/people?category=' + Discovery.current_category, function(result) {
        $('#people ul').html(result);
        $people.removeClass('loading');
      });

      return false;
		},
		
		on_resize: function() {
		  var height = $(window).height();
			$('#landing').css('height',height+'px');
		}
		
	});
	
	window.Discovery = new DiscoveryView;
	
});