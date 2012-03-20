window.ProfileView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #user-profile #tabs a': 'switch_info_tabs',
		'click #vertical-people h1 a': 'switch_supporter_tabs',
		'click #subscribe': 'subscribe'
	},
	
	initialize: function() {
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
  }
  
});

window.Profile = new ProfileView;