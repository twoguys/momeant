$(function() {
  
  window.Scroller = Backbone.View.extend({
		
		el: $('body'),
		
		events: {
			
		},
		
		initialize: function() {
		  this.index = 0;
		  this.current_position = 0;
		  this.$list = $(scrollables_selector);
		  var scrollables = [];
		  $.each($(scrollables_selector + ' li'), function(index, value) {
		    scrollables.push($(value).height() + 90); // bottom padding
		  });
		  this.scrollables = scrollables;
		  this.duration = 600;
		  this.settings = {easing: 'easeOutQuart'};
		  this.body_element = $('body');
		  this.body_scroll = 0;
		  //var body_height = $('body').height() + 15;
		  //$('body').css({height: body_height});
		  
		  _.bindAll(this, 'on_keypress');
		  $(document).bind('keydown', this.on_keypress);
		  
		  $.scrollTo(0);
		},
		
		on_keypress: function(event) {
		  var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
		  console.log(key);
		  switch (key) {
		    case 38: // up arrow
		      Scroll.to_prev();
		      event.preventDefault();
		      break;
		    case 40: // down arrow
		      Scroll.to_next();
		      event.preventDefault();
		      break;
		  }
		},
		
		to_next: function() {
		  if (Scroll.index == Scroll.scrollables.length - 1) { return; }
		  
		  var next_height = Scroll.scrollables[Scroll.index];
		  Scroll.index += 1;
		  Scroll.current_position -= next_height;
		  Scroll.$list.css({marginTop: Scroll.current_position});
		  //Scroll.body_scroll += next_height;
		  //Scroll.body_element.scrollTop(Scroll.body_scroll);
		  //$.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
		},
		
		to_prev: function() {
		  if (Scroll.index == 0) { return; }
		  
		  Scroll.index -= 1;
		  var prev_height = Scroll.scrollables[Scroll.index];
		  Scroll.current_position += prev_height;
		  Scroll.$list.css({marginTop: Scroll.current_position});
		  //Scroll.body_height -= prev_height;
		  //Scroll.body_element.css({height: Scroll.body_height});
		  //$.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
		}
		
	});
	
	window.Scroll = new Scroller;
	
});