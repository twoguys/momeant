$(function() {
  
  window.DiscoveryView = Backbone.View.extend({
		
		el: $('#main'),
		
		events: {
		  'click #goto-about': 'goto_about',
		  'click #goto-creators': 'goto_creators',
		  'click #goto-creators-secondary': 'goto_creators',
			'click #filter a': 'load_people',
			'click #people a': 'goto_person'
		},
		
		initialize: function() {
			this.current_category = undefined;
			this.has_gone_down = false;
			this.has_gone_right = false;
			
			var height = $(window).height();
			$('#landing').css('height',height+'px').find('#message, #goto-creators, #goto-about').fadeIn(1000);
			
			_.bindAll(this, 'on_resize');
  	  $(window).resize(this.on_resize);
  	  
  	  _.bindAll(this, 'on_keypress');
  	  $(document).bind('keydown', this.on_keypress);
  	  
  	  _.bindAll(this, 'goto_creators');
  	  _.bindAll(this, 'goto_about');
  	  _.bindAll(this, 'goto_landing');
  	  
  	  if (window.location.href.indexOf('browse') > -1) {
  	    this.goto_creators();
  	  }
		},
		
		reset: function() {
		  $('#loader').hide();
		  $('#messaging, #creators').css('margin-left',0);
		  $('#about').show();
  	  $.scrollTo(0);
		},
		
		goto_about: function() {
		  var height = $(window).height();
		  $.scrollTo(height, 500, {easing:'easeOutQuart'});
		  this.has_gone_down = true;
		  return false;
		},
		
		goto_creators: function() {
		  $('#goto-creators-secondary').hide();
      $('#messaging').animate({'margin-left': '-50%'}, 500, 'easeOutQuart', function() {
		    $.scrollTo(0, 300, {onAfter: function() {
		      $('#header').animate({top:0}, 300);
		    }});
		    $('#about').hide();
		  });
		  this.has_gone_right = true;
		  return false;
		},
		
		goto_landing: function() {
	    $('#messaging').animate({'margin-left': '0'}, 500, 'easeOutQuart', function() {
  		  $('#header').animate({top:'-60px'}, 300);
  		  $.scrollTo(0, 500);
        $('#about, #goto-creators-secondary').show();
      });
      this.has_gone_right = false;
      this.has_gone_down = false;
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
		
		goto_person: function(event) {
		  var $person = $(event.currentTarget);
		  $('#creators').animate({'margin-left': '-50%'}, 500, 'easeOutQuart', function() {
		    $('#loader').show();
		  });
		},
		
		on_resize: function() {
		  var height = $(window).height();
			$('#landing').css('height',height+'px');
		},
		
		on_keypress: function(event) {
		  var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
  	  switch (key) {
  	    case 40: // down arrow
  	      if (!this.has_gone_down) {
  	        this.goto_about();
    	      event.preventDefault();
  	      }
  	      break;
        case 39: // right arrow
          if (!this.has_gone_right) {
            this.goto_creators();
            event.preventDefault();
          }
          break;
        case 37: // left arrow
          if (this.has_gone_right) {
            this.goto_landing();
            event.preventDefault();
          }
          break;
  	  }
		}
		
	});
	
	window.Discovery = new DiscoveryView;
	window.onunload = function(){};
	Discovery.reset();
	
});