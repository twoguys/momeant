window.ProfileView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #subscribe':             'subscribe',
		'click #work-browser .list a':  'select_work'
	},
	
	initialize: function() {
	  this.set_width_for_ios();
	  
	  $('#and-more .icon').hover(function() {
	    $(this).siblings().fadeIn(200);
	  }, function() {
	    $(this).siblings().fadeOut(200);
	  });
  },
  
  set_width_for_ios: function() {
    var user_agent = navigator.userAgent.toLowerCase();
    if ((user_agent.indexOf('ipad') > -1) || (user_agent.indexOf('iphone') > -1)) {
      $('body, #header').css('width', '1300px');
    }
  },
  
  subscribe: function(event) {
    var $link = $(event.currentTarget);
    
    if ($link.text() == 'Follow') {
      $.post('/users/' + user_id + '/subscriptions');
      $link.text('Unfollow');
      show_feed_plus_one();
    } else {
      $.post('/users/' + user_id + '/subscriptions/unsubscribe');
      $link.text('Follow');
    }
    
    return false;
  },
  
  select_work: function(event) {
    var $content = $(event.currentTarget);
    var $preview = $('#activity-list');
    $preview.addClass('loading');
    $.get('/stories/' + $content.attr('data') + '/preview', function(result) {
      $preview.html(result).removeClass('loading');
    });
    $content.addClass('selected').parent().siblings().find('a').removeClass('selected');
    return false;
  }
  
});

window.BroadcasterView = Backbone.View.extend({
	
	el: $('#broadcaster'),
	
	events: {
		'click #post-update': 'show_update_form',
		'click #cancel-update': 'hide_update_form',
		'submit #new_broadcast': 'submit_broadcast'
	},
	
	initialize: function() {
  },
  
  show_update_form: function() {
    $('#new_broadcast').show();
    $('#updates-list').hide();
    return false;
  },
  
  hide_update_form: function() {
    $('#new_broadcast').hide();
    $('#updates-list').show();
    return false;
  },
  
  submit_broadcast: function(event) {
    var $form = $(event.currentTarget);
    event.preventDefault();
    
    var message = $form.find('#broadcast_message').val();
    var token = $form.find('input[name="authenticity_token"]').val();
    if (message == '') { return; }
    
    $form.find('#broadcast_message').val('');
    $form.addClass('loading');
    $.post('/users/' + user_id + '/broadcasts', {
      'broadcast[message]': message,
      authenticity_token: token
    }, function() {
      $form.removeClass('loading');
      $('#updates-list').text(message);
      Broadcaster.hide_update_form();
    });
  }
  
});

window.Profile = new ProfileView;
window.Broadcaster = new BroadcasterView;