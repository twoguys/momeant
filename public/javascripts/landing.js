$(function() {
  
  window.DiscoveryView = Backbone.View.extend({
		
		el: $('body'),
		
		events: {
			'click #people a': 'person_clicked'
		},
		
		initialize: function() {
			this.current_category = undefined;
			this.$window = $(window);
			this.window_height = this.$window.height();
			this.current_person = undefined;
			
			_.bindAll(this, 'on_resize');
  	  $(window).resize(this.on_resize);
  	  
  	  _.bindAll(this, 'on_keypress');
  	  $(document).bind('keydown', this.on_keypress);
		},
		
		reset: function() {
  	  $('#slides').scrollTo(0);
		},
		
		goto_messaging: function() {
		  $('#slides').scrollTo(0, 500, {easing:'easeOutQuart'});
		},
		
		person_clicked: function(event) {
		  var $person = $(event.currentTarget);
		  Discovery.goto_person($person);
		},
		
		goto_person: function($person) {
		  Discovery.current_person = $person;
		  $person.parent().removeClass('faded').siblings().addClass('faded');
		  var id = $person.attr('data');
		  var $person_slide = $('#slides #person-' + id);
		  $('#slides').scrollTo($person_slide, 500, {easing: 'easeOutQuart'});
		},
		
		next_person: function() {
		  if (Discovery.current_person == undefined) {
		    Discovery.goto_person($('#people #list li:first-child a'));
		  } else {
		    var $next = Discovery.current_person.parent().next();
		    if ($next.length == 0) { return false; } // we're on the last person in the list
  		  Discovery.goto_person($next.find('a'));
		  }
		  return false;
		},
		
		prev_person: function() {
		  if (Discovery.current_person == undefined) {
		    Discovery.goto_person($('#people #list li:first-child a'));
		  } else {
		    var $prev = Discovery.current_person.parent().prev();
		    if ($prev.length == 0) { // we're on the first person in the list
  	      Discovery.current_person = undefined;
		      Discovery.goto_messaging();
		      $('#people #list li').removeClass('faded');
		      return false;
		    }
  		  Discovery.goto_person($prev.find('a'));
		  }
		  return false;
		},
		
		on_resize: function() {
		  this.window_height = this.$window.height();
		},
		
		on_keypress: function(event) {
		  var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
  	  switch (key) {
  	    case 40: // down arrow
  	      this.next_person();
  	      break;
        case 38: // up arrow
          this.prev_person();
          break;
  	  }
		}
		
	});
	
	window.Discovery = new DiscoveryView;
	window.onunload = function(){};
	Discovery.reset();
	
});