window.LandingView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
	  'click #previous':    'previous_slide',
	  'click #next':        'next_slide'
	},
	
	initialize: function() {
	  this.current_width = 0;
	  this.current_slide = 0;
	  
		_.bindAll(this, 'set_widths', 'previous_slide', 'next_slide', 'update_arrow_inactivity');
	  $(window).resize(this.set_widths);
	  
		this.set_widths();
	},
	
	set_widths: function() {
	  var page_width = $('#main').width();
	  this.current_width = page_width;
	  $('#slides li').css('width', page_width);
	  $('#slides ul').css('width', page_width * 7);
	  $('#people').css('width', page_width + 50);
	},
	
	previous_slide: function() {
	  if (this.current_slide == 0) { return false; }
	  this.current_slide -= 1;
	  $('#slides ul').css('margin-left', this.current_width * this.current_slide * -1);
	  this.update_arrow_inactivity();
	  return false;
	},
	
	next_slide: function() {
	  if (this.current_slide == 6) { return false; }
	  this.current_slide += 1;
	  $('#slides ul').css('margin-left', this.current_width * this.current_slide * -1);
	  this.update_arrow_inactivity();
	  return false;
	},
	
	update_arrow_inactivity: function() {
	  $('#previous, #next').removeClass('inactive');
	  if (this.current_slide == 0) {
	    $('#previous').addClass('inactive');
	  } else if (this.current_slide == 6) {
	    $('#next').addClass('inactive');
	  }
	}
	
});

window.Landing = new LandingView;
window.onunload = function(){};