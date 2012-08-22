window.LandingView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
	  'click #previous':          'previous_slide',
	  'click #next':              'next_slide',
	  'click #continue-downward': 'continue_downward'
	},
	
	initialize: function() {
	  this.current_width = 0;
	  this.current_slide = 0;
	  
		_.bindAll(this, 'set_widths', 'previous_slide', 'next_slide', 'update_arrow_inactivity');
	  $(window).resize(this.set_widths);
	  
	  _.bindAll(this, 'on_keypress');
	  $(window).keypress(this.on_keypress);
	  
		this.set_widths();
	},
	
	set_widths: function() {
	  var page_width = $('#main').width();
	  this.current_width = page_width;
	  $('#slides li').css('width', page_width);
	  $('#slides ul').css('width', page_width * 5);
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
	  if (this.current_slide == 4) { return false; }
	  this.current_slide += 1;
	  $('#slides ul').css('margin-left', this.current_width * this.current_slide * -1);
	  this.update_arrow_inactivity();
	  return false;
	},
	
	update_arrow_inactivity: function() {
	  $('#previous, #next').removeClass('inactive');
	  if (this.current_slide == 0) {
	    $('#previous').addClass('inactive');
	  } else if (this.current_slide == 4) {
	    $('#next').addClass('inactive');
	  }
	},
	
	continue_downward: function() {
	  $.scrollTo(660,300);
	  return false;
	},
	
	on_keypress: function(event) {
    if (currently_editing_text) { return; }
        
    var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
    switch (key) {
      case 37: // left arrow
        this.previous_slide();
        event.preventDefault();
        break;
      case 39: // right arrow
        this.next_slide();
        event.preventDefault();
        break;
    }
	}
	
});

window.Landing = new LandingView;
window.onunload = function(){};