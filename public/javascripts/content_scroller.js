window.Scroller = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click a.content-preview': 'expand_content'
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
	    var $content = $(value);
	    var content_info = {
	      height: $content.height(),
	      top: $content.offset().top - 120, // subtract space between top of browser and where content starts
	      bottom: $content.offset().top - 120 + $content.height()
	    };
	    scrollables.push(content_info);
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
      // case 39: // right arrow
      //   this.to_content();
      //   event.preventDefault();
      //   break;
	  }
	},
	
	on_scroll: function() {
	  var distance_from_top = $(document).scrollTop() + 140; // buffer it by 180
    var index = 0;
	  while (index < Scroll.scrollables.length) {
	    if (distance_from_top > Scroll.scrollables[index].top && distance_from_top < Scroll.scrollables[index].bottom) {
	      $('#content-list li:nth-child(' + (index + 1) + ')').addClass('current').siblings().removeClass('current');
	      Scroll.index = index;
	      //Scroll.current_position = Scroll.scrollables[index].top;
	      break;
	    }
	    index++;
	  }
	},
	
	to_next: function() {
	  if (Scroll.index == Scroll.scrollables.length - 1) { return; }
	  
	  Scroll.index += 1;
	  Scroll.current_position = Scroll.scrollables[Scroll.index].top;
	  //$('#vertical-content').css('margin-top',-Scroll.current_position);
	  $.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
	},
	
	to_prev: function() {
	  if (Scroll.index == 0) { return; }
	  
	  Scroll.index -= 1;
	  Scroll.current_position = Scroll.scrollables[Scroll.index].top;
	  //$('#vertical-content').css('margin-top',-Scroll.current_position);
	  $.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
	},
	
	to_content: function() {
	  var url = $('#content-list li:nth-child(' + (Scroll.index + 1) + ') a.title').attr('href');
	  window.location.href = url;
	},
	
	expand_content: function(event) {
	  $('#main').css('position','fixed');
	  $('#vertical-people').css('left','auto');
	  $('#main, #vertical-people').animate({'right':'100%'}, 500, 'easeOutQuart', function() {
	    $('#loader').fadeIn(100);
	  });
	},
	
	reset: function() {
	  $('#loader').hide();
	}
	
});

window.Scroll = new Scroller;
window.onunload = function(){};
Scroll.reset();