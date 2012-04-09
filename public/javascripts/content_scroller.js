window.Scroller = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #activity-list li a.content-preview': 'clicked_content',
		'click #activity-list li a.title': 'clicked_content',
		'focus textarea': 'start_editing_text',
		'blur textarea': 'stop_editing_text',
		'submit #new_message': 'post_message',
		'click a.open-comments': 'show_comments',
		'click a.close-comments': 'hide_comments'
	},
	
	initialize: function() {
	  this.index = 0;
	  this.current_position = 0;
	  this.$list = $(scrollables_selector);
	  this.scrollables = [];
	  this.duration = 600;
	  this.settings = {easing: 'easeOutQuart'};
	  this.editing_text = false;
	  
	  this.calculate_list_heights();
	  this.pad_bottom();
	  $('#activity-list > li:first-child').addClass('current');
	  
	  _.bindAll(this, 'on_keypress');
	  $(document).bind('keydown', this.on_keypress);
	  
	  _.bindAll(this, 'on_resize');
	  $(window).resize(this.on_resize);
	  
	  $.scrollTo(0);
	},
	
	calculate_list_heights: function() {
	  var scrollables = [];
	  $.each($(scrollables_selector + ' > li'), function(index, value) {
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
	  var content_list = $('#activity-list').height();
	  var last_content_height = 0;
	  if (this.scrollables.length > 0) {
	    last_content_height = this.scrollables[this.scrollables.length - 1].height;
    }
	  var new_body_height = viewport_height + content_list - last_content_height;
	  $('body').css({height: new_body_height});
	},
	
	on_resize: function() {
	  this.calculate_list_heights();
	  this.pad_bottom();
	},
	
	on_keypress: function(event) {
    //     if (this.editing_text) { return; }
    //     
    // var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
    // switch (key) {
    //   case 38: // up arrow
    //     this.to_prev();
    //     event.preventDefault();
    //     break;
    //   case 40: // down arrow
    //     this.to_next();
    //     event.preventDefault();
    //     break;
    //       case 39: // right arrow
    //         var url = $('#activity-list li:nth-child(' + (Scroll.index + 1) + ') a.title').attr('href');
    //         this.to_content(url);
    //         event.preventDefault();
    //         break;
    // }
	},
	
	to_next: function() {
	  if (Scroll.scrollables.length == 0) { return; }
	  if (Scroll.index == Scroll.scrollables.length - 1) { return; }
	  $.scrollTo(0);
	  
	  Scroll.index += 1;
	  Scroll.current_position = Scroll.scrollables[Scroll.index].top;
	  $('#vertical-list').css('margin-top',-Scroll.current_position);
	  //$.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
	},
	
	to_prev: function() {
	  if (Scroll.index == 0) { return; }
	  $.scrollTo(0);
	  
	  Scroll.index -= 1;
	  Scroll.current_position = Scroll.scrollables[Scroll.index].top;
	  $('#vertical-list').css('margin-top',-Scroll.current_position);
	  //$.scrollTo(Scroll.current_position, Scroll.duration, Scroll.settings);
	},
	
	to_content: function(url) {
	  window.location.href = url;
	  $('#header').css('top','-60px');
	  $('#main').css('position','fixed');
	  $('#vertical-people').css('left','auto');
	  $('#main, #vertical-people').animate({'right':'100%'}, 500, 'easeOutQuart', function() {
	    $('#loader').show();
	  });
	},
	
	clicked_content: function(event) {
	  var url = $(event.currentTarget).attr('href');
	  Scroll.to_content(url);
	  return false;
	},
	
	start_editing_text: function() {
	  Scroll.editing_text = true;
	},

	stop_editing_text: function() {
	  Scroll.editing_text = false;
	},
  
  post_message: function(event) {
    var $form = $(event.currentTarget);
    event.preventDefault();
    
    var body = $form.find('#message_body').val();
    var token = $form.find('input[name="authenticity_token"]').val();
    $('#message_body').val('');
    $form.addClass('loading');
    
    $.post('/users/' + user_id + '/messages/public', {
      'message[body]': body,
      'authenticity_token': token,
      'public': true
    }, function(html) {
      $('#discussion ul').prepend(html);
      $form.removeClass('loading');
    });
  },
  
  show_comments: function(event) {
    var $link = $(event.currentTarget);
    var $comments = $link.siblings('.insides');
    $link.hide();
    $comments.show();
    return false;
  },
  
  hide_comments: function(event) {
    var $comments = $(event.currentTarget).parent();
    var $link = $comments.siblings('a.open-comments');
    $comments.hide();
    $link.show();
    return false;
  },
  
	reset: function() {
	  $('#loader').hide();
	}
	
});

window.Scroll = new Scroller;
window.onunload = function(){};
Scroll.reset();