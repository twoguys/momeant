window.PatronageView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #carousel a': 'filter_person'
	},
	
	initialize: function() {
	  this.ensure_body_is_full_height();
	  
	  _.bindAll(this, 'on_resize');
	  $(window).resize(this.on_resize);
  },
  
  ensure_body_is_full_height: function() {
    var body_height = $('body').height();
    var viewport_height = $(window).height();
    if (body_height < viewport_height) {
      $('body').css('height', viewport_height);
    } else {
      $('body').css('height', 'auto');
    }
  },
  
  filter_person: function(event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('selected')) {
      Patronage.show_all_people($link);
      return false;
    }
    
    $('#vertical-list').addClass('filtered');
    var id = $link.attr('data');
    $link.addClass('selected').siblings().removeClass('selected');
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/patronage_filter?creator_id=' + id, function(html) {
      $('#activity-list').html(html).removeClass('loading');
    });
    
    return false;
  },
  
  show_all_people: function($link) {
    $('#vertical-list').removeClass('filtered');
    $link.removeClass('selected');
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/patronage_filter', function(html) {
      $('#activity-list').html(html).removeClass('loading');
    });
  },
  
  on_resize: function() {
    this.ensure_body_is_full_height();
  }
  
});

window.Patronage = new PatronageView;