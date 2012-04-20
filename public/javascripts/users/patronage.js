window.PatronageView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #carousel a': 'filter_person'
	},
	
	initialize: function() {
	  this.ensure_body_is_full_height();
	  
	  if (my_page) {
	    this.make_reward_reason_editable();
	  }
	  
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
  
  make_reward_reason_editable: function() {
    $('#edit-reward-reason').editInPlace({
  		url: '/users/' + user_id + '/update_in_place',
  		params: 'attribute=i_reward_because',
  		field_type: 'textarea',
  		textarea_cols: 65,
  		textarea_rows: 1,
  		show_buttons: true
  	});
  	$('#statement em').click(function() {
  	  $('#edit-reward-reason').click();
  	});
  },
  
  filter_person: function(event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('selected')) {
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
  
  on_resize: function() {
    this.ensure_body_is_full_height();
  }
  
});

window.Patronage = new PatronageView;