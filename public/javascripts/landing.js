window.DiscoveryView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #faces a':       'face_clicked',
		'click #categories a':  'category_clicked'
	},
	
	initialize: function() {
		this.current_category = 'Featured';
		this.person_width = $('#people li.person:first-child').width();
		this.faces = $('#faces #list');
		this.people_slider = $('#people > ul');
		
		this.landing = $('#landing-page');
		this.on_resize();
		_.bindAll(this, 'on_resize');
    $(window).resize(this.on_resize);
	},
	
	face_clicked: function(event) {
	  var $face = $(event.currentTarget).parent();
	  $face.addClass('selected').siblings().removeClass('selected');
	  var index = parseInt($face.attr('data'));
	  Discovery.goto_person(index);
	  return false;
	},
	
	category_clicked: function(event) {
	  var $category = $(event.currentTarget).parent();
	  $category.addClass('selected').siblings().removeClass('selected');
	  Discovery.people_slider.css('margin',0).addClass('loading');
	  $.get('/people', {category: $category.find('a').text()}, function(result) {
	    Discovery.faces.html(result.faces);
	    Discovery.people_slider.html(result.people).removeClass('loading');
	    Discovery.setup_following_buttons();
	  });
	  
	  return false;
	},
	
	goto_person: function(index) {
	  var position = index * Discovery.person_width * -1;
	  Discovery.people_slider.css('margin-left', position);
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