window.DiscoveryView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #people a.name': 'person_clicked'
	},
	
	initialize: function() {
		this.current_category = undefined;
		this.$window = $(window);
		this.current_person = -1;
		this.people = [];
		this.$slides = $('.slide');
    this.store_people();
    this.typing = false;
		
		_.bindAll(this, 'on_resize');
	  $(window).resize(this.on_resize);
	  this.on_resize();
	  
	  _.bindAll(this, 'on_keypress');
	  $(document).bind('keydown', this.on_keypress);
	  
	  Discovery.stop_arrow_keys_during_typing();
	},
	
	store_people: function() {
		var people = [];
		$.each($('#people #list a.name'), function(index, person) {
		  var $person = $(person);
		  people.push($person);
		});
		this.people = people;
	},
	
	stop_arrow_keys_during_typing: function() {
	  $('input').each(function(index, input) {
	    var $input = $(input);
	    $input.focus(function() { Discovery.typing = true; });
	    $input.blur(function() { Discovery.typing = false; })
	  });
	},
	
	reset: function() {
	  var index = $.cookie('discovery_creator_index');
	  if (index == null) { return; }
	  var index = parseInt(index);
	  if (index > Discovery.people.length - 1) { return; }
    Discovery.goto_person(index);
	},
	
	person_clicked: function(event) {
    var index = $(event.currentTarget).parent().index();
    Discovery.goto_person(index);
	  return false;
	},
	
	goto_person: function(index) {
    Discovery.current_person = index;
    if (Discovery.current_person == -1) { // go to messaging slide
      $('#slides').css('margin-top',0);
      $('#people li').removeClass('current faded');
      $.cookie('discovery_creator_index', null);
      return;
    }
    var $person = Discovery.people[index];
    $person.parent().addClass('current').removeClass('faded').siblings().removeClass('current').addClass('faded');
    var scroll_to = Discovery.window_height * (index + 1) * -1;
    $('#slides').css('margin-top', scroll_to);
    $.cookie('discovery_creator_index', index);
	},
	
	next_person: function() {
	  if (Discovery.current_person == Discovery.people.length - 1) { return; }
	  Discovery.goto_person(Discovery.current_person + 1);
	},
	
	prev_person: function() {
	  if (Discovery.current_person < 0) { return; }
    Discovery.goto_person(Discovery.current_person - 1);
	},
	
	goto_profile: function() {
    if (Discovery.current_person < 0) { return false; }
    var href = Discovery.people[Discovery.current_person].attr('href');
    $('#main').css('right','100%');
    setTimeout(function() {$('#loader').show();}, 200);
    window.location.href = href;
  },
  
	on_resize: function() {
	  this.window_height = this.$window.height() - 42;
	  this.$slides.css('height',this.window_height);
	},
	
	on_keypress: function(event) {
	  if (this.typing) { return; }
	  var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
	  switch (key) {
	    case 40: // down arrow
	      this.next_person();
	      break;
      case 38: // up arrow
        this.prev_person();
        break;
      case 39: // right arrow
        this.goto_profile();
        break;
	  }
	}
	
});

$(function() {
  window.Discovery = new DiscoveryView;
  window.onunload = function(){};
  Discovery.reset();
});