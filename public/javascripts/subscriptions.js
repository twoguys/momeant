window.SubscriptionsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #feed-sidebar a.following': 'filter_person',
		'click #user-nav #feed a':    'show_all_people',
    'click .back-to-feed':        'show_all_people',
		'click a.drill-in':           'drill_in'
	},
	
	initialize: function() {
	  this.set_width_for_ios();
  },
  
  set_width_for_ios: function() {
    var user_agent = navigator.userAgent.toLowerCase();
    if ((user_agent.indexOf('ipad') > -1) || (user_agent.indexOf('iphone') > -1)) {
      $('body, #header').css('width', '1300px');
    }
  },
  
  filter_person: function(event) {
    var $person = $(event.currentTarget);
    if ($person.hasClass('selected')) {
      $person.removeClass('selected');
      Subscriptions.show_all_people();
      return false;
    }
    Subscriptions.drill_in(event);
    return false;
  },
  
  show_all_people: function() {
    $('#feed-sidebar a.following').removeClass('selected');
    $('#recent-activity').addClass('loading').removeClass('drilled-in');
    $.get('/feed?remote=true', function(html) {
      $('#recent-activity').html(html).removeClass('loading');
    });
    return false;
  },
  
  drill_in: function(event) {
    var $link = $(event.currentTarget);
    $('#recent-activity').addClass('loading drilled-in');
    $.ajax({
      url: $link.attr('href'),
      type: 'GET',
      dataType: 'text',
      success: function(html) { $('#recent-activity').html(html).removeClass('loading'); }
    });
    return false;
  }
  
});

window.Subscriptions = new SubscriptionsView;