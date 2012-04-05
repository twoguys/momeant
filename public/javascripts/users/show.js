window.ProfileView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #user-profile #tabs a': 'switch_info_tabs',
		'click #vertical-people h1 a': 'switch_supporter_tabs',
		'click #subscribe': 'subscribe'
	},
	
	initialize: function() {
	  _.bindAll(this, 'on_keypress');
	  $(document).bind('keydown', this.on_keypress);
	  this.auto_resize_discussion_box();
  },

  auto_resize_discussion_box: function() {
    $('#message_body').autoResize({minHeight:15, extraSpace:5});
  },
  
  switch_info_tabs: function(event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('selected')) { return false; }
    
    $link.addClass('selected').siblings().removeClass('selected');
    var $text = $('#tabs #text .' + $link.text().toLowerCase());
    $text.removeClass('hidden').siblings().addClass('hidden');
    
    return false;
  },
  
  switch_supporter_tabs: function(event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('selected')) { return false; }
    
    $link.addClass('selected').siblings().removeClass('selected');
    var $text = $('#vertical-people #' + $link.text().toLowerCase());
    $text.removeClass('hidden').siblings().addClass('hidden');
    
    return false;
  },
  
  subscribe: function(event) {
    var $link = $(event.currentTarget);
    
    if ($link.text() == 'Subscribe') {
      $.post('/users/' + user_id + '/subscriptions');
      $link.text('Unsubscribe');
    } else {
      $.post('/users/' + user_id + '/subscriptions/unsubscribe');
      $link.text('Subscribe');
    }
    
    return false;
  },
	
	back: function() {
	  window.history.back();
	  $('#vertical-people').css('right','-100%');
	  $('#container').css('margin-left','100%');
	  setTimeout(function() { $('#loader').show(); }, 200);
	},
  
  on_keypress: function(event) {
    if (Profile.editing_text) { return; }
    
    var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
	  switch (key) {
	    case 37: // left arrow
	      this.back();
	      event.preventDefault();
	      break;
	    case 68: // letter 'd'
	      
    }
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
  },
  
  hide_update_form: function() {
    $('#new_broadcast').hide();
    $('#updates-list').show();
  },
  
  submit_broadcast: function(event) {
    var $form = $(event.currentTarget);
    event.preventDefault();
    
    var message = $form.find('#broadcast_message').val();
    var token = $form.find('input[name="authenticity_token"]').val();
    if (message == '') { return; }
    
    $form.addClass('loading');
    $.post('/users/' + user_id + '/broadcasts', {
      'broadcast[message]': message,
      authenticity_token: token
    }, function() {
      $form.removeClass('loading');
      $('#latest-update').text(message);
      Broadcaster.hide_update_form();
    });
  }
  
});

window.Profile = new ProfileView;
window.Broadcaster = new BroadcasterView;