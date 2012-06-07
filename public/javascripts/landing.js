window.DiscoveryView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #categories a.top':          'category_clicked',
		'click #categories .people a':      'person_clicked',
		'click .actions a.follow':          'subscribe',
		'click .person .more .next':        'next_person_content',
		'click .person .more .prev':        'prev_person_content',
		'click #featured-content .toggler': 'toggle_featured_content'
	},
	
	initialize: function() {
		this.current_category = 'Featured';
		this.person_height = $('#people li.person:first-child').height();
		this.people_slider = $('#people > ul');
		this.people = $('#categories .people a');
		
		this.set_creator_content_list_lengths();
	},
	
	set_creator_content_list_lengths: function() {
	  $('#people .person .list').each(function() {
	    var $list = $(this);
	    var content_count = parseInt($list.attr('total'));
	    $list.css('width', content_count * 304);
	  });
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
	
	subscribe: function(event) {
    var $link = $(event.currentTarget);
    var user_id = $link.attr('data');
    
    if ($link.text() == 'Follow') {
      $.post('/users/' + user_id + '/subscriptions');
      $link.text('Unfollow');
      show_feed_plus_one();
    } else {
      $.post('/users/' + user_id + '/subscriptions/unsubscribe');
      $link.text('Follow');
    }
    
    return false;
  },
  
  next_person_content: function(event) {
    var $link = $(event.currentTarget);
    var $list = $link.parent().siblings('.list');
    var current = parseInt($list.attr('current')) + 1;
    var total = parseInt($list.attr('total'));
    if (current == total) { return false; }
    $list.css('margin-left', -1 * current * 304);
    $list.attr('current', current);
    $link.siblings('.prev').removeClass('off');
    if (current + 1 == total) { $link.addClass('off'); }
    return false;
  },
  
  prev_person_content: function(event) {
    var $link = $(event.currentTarget);
    var $list = $link.parent().siblings('.list');
    var current = parseInt($list.attr('current')) - 1;
    if (current == -1) { return false; }
    $list.css('margin-left', -1 * current * 304);
    $list.attr('current', current);
    $link.siblings('.next').removeClass('off');
    if (current == 0) { $link.addClass('off'); }
    return false;
  },
  
  toggle_featured_content: function(event) {
    var $media_type = $(event.currentTarget).parent();
    if ($media_type.hasClass('open')) { return false; }
    
    $media_type.addClass('open').siblings().removeClass('open');
  }
	
});

window.Discovery = new DiscoveryView;
window.onunload = function(){};