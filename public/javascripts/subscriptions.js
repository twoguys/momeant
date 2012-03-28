window.SubscriptionsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #vertical-people a': 'filter_person'
	},
	
	initialize: function() {
  },
  
  filter_person: function(event) {
    var $link = $(event.currentTarget);
    console.log($link.parent());
    if ($link.parent().hasClass('current')) {
      Subscriptions.show_all_people($link);
      return false;
    }
    
    var id = $link.attr('data');
    $link.parent().addClass('current').removeClass('dimmed').siblings().addClass('dimmed');
    $.scrollTo(0);
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/subscriptions/filter?id=' + id, function(html) {
      $('#activity-list').html(html).removeClass('loading').find('li:first-child').addClass('current');
      Scroll.on_resize();
    });
    
    return false;
  },
  
  show_all_people: function($link) {
    $link.parent().parent().find('li').removeClass('dimmed');
    $.scrollTo(0);
    $('#activity-list').addClass('loading');
    $.get('/users/' + user_id + '/subscriptions/filter', function(html) {
      $('#activity-list').html(html).removeClass('loading').find('li:first-child').addClass('current');
      Scroll.on_resize();
    });
  }
  
});

window.Subscriptions = new SubscriptionsView;