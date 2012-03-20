window.SubscriptionsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #vertical-people a': 'filter_person'
	},
	
	initialize: function() {
  },
  
  filter_person: function(event) {
    var $link = $(event.currentTarget);
    if ($link.attr('id') == 'find-creators') { return; }
    
    var id = $link.attr('data');
    $link.parent().removeClass('dimmed').siblings().addClass('dimmed');
    $.scrollTo(0);
    $('#content-list').addClass('loading');
    $.get('/users/' + user_id + '/subscriptions/filter/' + id, function(html) {
      $('#content-list').html(html).removeClass('loading').find('li:first-child').addClass('current');
      Scroll.on_resize();
    });
    
    return false;
  }
  
});

window.Subscriptions = new SubscriptionsView;