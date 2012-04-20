window.SubscriptionsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #feed-left li': 'filter_person'
	},
	
	initialize: function() {
  },
  
  filter_person: function(event) {
    var $person = $(event.currentTarget);
    if ($person.hasClass('selected')) {
      $('#feed-left li').removeClass('selected');
      Subscriptions.show_all_people($person);
      return false;
    }
    
    var id = $person.attr('data');
    $('#feed-left li').removeClass('selected');
    $person.addClass('selected');
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/subscriptions/filter?id=' + id, function(html) {
      $('#activity-list').html(html).removeClass('loading');
    });
    
    return false;
  },
  
  show_all_people: function($link) {
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/subscriptions/filter', function(html) {
      $('#activity-list').html(html).removeClass('loading');
    });
  }
  
});

window.Subscriptions = new SubscriptionsView;