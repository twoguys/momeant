$(function() {
  
  window.Scroller = Backbone.View.extend({
		
		el: $('body'),
		
		events: {
			
		},
		
		initialize: function() {
		  this.index = 0;
		  this.current_position = 0;
		  this.$list = $(scrollables_selector);
		  this.scrollables = [];
		  this.duration = 600;
		  this.settings = {easing: 'easeOutQuart'};
		  
		  this.calculate_list_heights();
		  this.pad_bottom();
		  $('#content-list li:first-child').addClass('current');
		  
		  _.bindAll(this, 'on_keypress');
		  $(document).bind('keydown', this.on_keypress);
		  
		  _.bindAll(this, 'on_resize');
		  $(window).resize(this.on_resize);
		  
		  _.bindAll(this, 'on_scroll');
		  $(document).scroll(this.on_scroll);
		  
		  $.scrollTo(0);
		},
		
		calculate_list_heights: function() {
		  var scrollables = [];
		  $.each($(scrollables_selector + ' li'), function(index, value) {
		    scrollables.push({height: $(value).height() + 90}); // bottom padding
		  });
		  this.scrollables = scrollables;
		},
		
		pad_bottom: function() {
		  var viewport_height = $(window).height();
		  var content_list = $('#content-list').height();
		  var last_content_height = this.scrollables[this.scrollables.length - 1].height;
		  var new_body_height = viewport_height + content_list - last_content_height;
		  $('body').css({height: new_body_height});
		},
		
		on_resize: function() {
		  this.calculate_list_heights();
		  this.pad_bottom();
		},
		
		on_keypress: function(event) {
		  var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
		  switch (key) {
		    case 38: // up arrow
		      this.to_prev();
		      event.preventDefault();
		      break;
		    case 40: // down arrow
		      this.to_next();
		      event.preventDefault();
		      break;
		  }
		},
		
		on_scroll: function() {
		  console.log($(document).scrollTop());
		},
		
		to_next: function() {
		  if (Scroll.index == Scroll.scrollables.length - 1) { return; }
		  
		  var next_height = Scroll.scrollables[Scroll.index].height;
		  Scroll.index += 1;
		  Scroll.current_position += next_height;
		  $.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
		  
		  Scroll.handle_fade();
		},
		
		to_prev: function() {
		  if (Scroll.index == 0) { return; }
		  
		  Scroll.index -= 1;
		  var prev_height = Scroll.scrollables[Scroll.index].height;
		  Scroll.current_position -= prev_height;
		  $.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
		  
		  Scroll.handle_fade();
		},
		
		handle_fade: function() {
		  $('#content-list li:nth-child(' + (Scroll.index + 1) + ')').addClass('current').siblings().removeClass('current');
		}
		
	});
	
	window.Scroll = new Scroller;
	
});