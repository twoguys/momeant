window.SupportView = Backbone.View.extend({
  
  el: $('#support'),
	
	events: {
		'click #vertical-people a': 'filter_person'
	},
	
	initialize: function() {
  },
  
  filter_person: function(event) {
    var $link = $(event.currentTarget);
    var id = $link.attr('data');
    $link.parent().removeClass('dimmed').siblings().addClass('dimmed');
    $.scrollTo(0);
    $('#content-list').addClass('loading');
    $.get('/support/' + id, function(html) {
      $('#content-list').html(html).removeClass('loading').find('li:first-child').addClass('current');
      Scroll.on_resize();
    });
    
    return false;
  }
  
});

window.Support = new SupportView;