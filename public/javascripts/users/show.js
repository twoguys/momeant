window.ProfileView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #user-profile #tabs a': 'switch_info_tabs',
		'click #vertical-people h1 a': 'switch_supporter_tabs',
		'click #subscribe': 'subscribe'
	},
	
	initialize: function() {
	  this.scroll_to_content();
	  
	  _.bindAll(this, 'on_keypress');
	  $(document).bind('keydown', this.on_keypress);
  },
  
  scroll_to_content: function() {
    var content_id_index = window.location.href.indexOf('?content=');
    if (content_id_index < 0) { return; }
    
    var content_id = window.location.href.substring(content_id_index + 9, window.location.href.length);
    var y_position = $('#content-' + content_id).position().top - 42;
    if (y_position < 0) { return; }
    console.log(y_position);
    $.scrollTo(y_position);
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
    
    if ($link.text() == 'Follow') {
      $.post('/users/' + user_id + '/subscriptions');
      $link.text('Unfollow');
    } else {
      $.post('/users/' + user_id + '/subscriptions/unsubscribe');
      $link.text('Follow');
    }
    
    return false;
  },
  
  on_keypress: function(event) {
    if (Profile.editing_text) { return; }
    var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
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