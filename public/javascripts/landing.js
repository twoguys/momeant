$(function() {
  
  window.DiscoveryView = Backbone.View.extend({
		
		el: $('#main'),
		
		events: {
			'click #filter a': 'load_people'
		},
		
		initialize: function() {
			this.current_category = undefined;
		},
		
		load_people: function(event) {
		  var $link = $(event.currentTarget);
		  if ($link.hasClass('selected')) {
		    Discovery.current_category = '';
		    $link.removeClass('selected');
		  } else {
		    $link.addClass('selected').parent().siblings().find('a').removeClass('selected');
        Discovery.current_category = $link.text();
		  }
      
      $('#choose-a-category:visible').fadeOut(200);
      var $people = $('#people');
      if (!$people.is(':visible')) { $people.show(); }
      $people.addClass('loading');
      $.get('/people?category=' + Discovery.current_category, function(result) {
        $('#people ul').html(result);
        $people.removeClass('loading');
      });

      return false;
		}
		
	});
	
	window.Discovery = new DiscoveryView;
	
});