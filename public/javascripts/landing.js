window.DiscoveryView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #categories a.top':      'category_clicked',
		'click #categories .people a':  'person_clicked'
	},
	
	initialize: function() {
		this.current_category = 'Featured';
		this.person_height = $('#people li.person:first-child').height();
		this.people_slider = $('#people > ul');
		this.people = $('#categories .people a');
		
		this.landing = $('#landing-page');
		this.on_resize();
		_.bindAll(this, 'on_resize');
    $(window).resize(this.on_resize);
	},
	
	category_clicked: function(event) {
	  var $category = $(event.currentTarget).parent();
	  $category.addClass('selected').siblings().removeClass('selected');
	  var $person = $category.find('.people a:first-child');
	  if ($person.length > 0) {
	    Discovery.goto_person($person);
	  }
	  return false;
	},
	
	person_clicked: function(event) {
	  var $person = $(event.currentTarget);
	  Discovery.goto_person($person);
	  return false;
	},
	
	goto_person: function($person) {
    Discovery.people.removeClass('selected');
    $person.addClass('selected');
    var index = parseInt($person.attr('data'));
	  var position = index * Discovery.person_height * -1;
	  Discovery.people_slider.css('margin-top', position);
	},
	
	setup_following_buttons: function() {
	  
	},
	
	on_resize: function() {
	  var landing_height = this.landing.height();
	  var window_height = $(window).height() - 42;
	  if (landing_height < window_height) {
	    this.landing.css('height',window_height + 'px');
	  }
	}
	
});

window.Discovery = new DiscoveryView;
window.onunload = function(){};