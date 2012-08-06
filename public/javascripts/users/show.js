window.ProfileView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		'click #subscribe':                 'subscribe',
		'click #work-browser .list a':      'select_work',
		'click #rewards-browser .list a':   'select_reward',
		'click .paginator .up':             'paginate_up',
		'click .paginator .down':           'paginate_down',
		'click #community .side-tabs a':    'switch_community_tabs'
	},
	
	initialize: function() {
	  this.set_width_for_ios();
	  
	  $('#and-more .icon').hover(function() {
	    $(this).siblings().fadeIn(200);
	  }, function() {
	    $(this).siblings().fadeOut(200);
	  });
  },
  
  set_width_for_ios: function() {
    var user_agent = navigator.userAgent.toLowerCase();
    if ((user_agent.indexOf('ipad') > -1) || (user_agent.indexOf('iphone') > -1)) {
      $('body, #header').css('width', '1300px');
    }
  },
  
  subscribe: function(event) {
    var $link = $(event.currentTarget);
    
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
  
  select_work: function(event) {
    var $content = $(event.currentTarget);
    var $preview = $('#work-browser #activity-list');
    $preview.addClass('loading');
    $.get('/stories/' + $content.attr('data') + '/preview', function(result) {
      $preview.html(result).removeClass('loading');
    });
    $content.addClass('selected').parent().siblings().find('a').removeClass('selected');
    return false;
  },
  
  select_reward: function(event) {
    var $content = $(event.currentTarget);
    var $preview = $('#rewards-browser #activity-list');
    $preview.addClass('loading');
    $.get('/stories/' + $content.attr('data') + '/preview', function(result) {
      $preview.html(result).removeClass('loading');
    });
    $content.addClass('selected').parent().siblings().find('a').removeClass('selected');
    return false;
  },
  
  paginate_up: function(event) {
    var $button = $(event.currentTarget);
    var $list = $button.siblings('.list');
    var current = parseInt($list.attr('current'));
    var total = parseInt($list.attr('total'));
    if (current == 0) { return false; }
    current--;
    var height_of_list = $list.height() + 5;
    $list.find('ul').css('margin-top', current * height_of_list * -1);
    $list.attr('current', current);
    if (current == 0) { $button.addClass('off') }
    else { $button.removeClass('off'); }
    if (current < total) { $button.siblings('.down').removeClass('off'); }
    return false;
  },
  
  paginate_down: function(event) {
    var $button = $(event.currentTarget);
    var $list = $button.siblings('.list');
    var current = parseInt($list.attr('current'));
    var total = parseInt($list.attr('total'));
    if (current >= total) { return false; }
    current++;
    var height_of_list = $list.height() + 5;
    $list.find('ul').css('margin-top', current * height_of_list * -1);
    $list.attr('current', current);
    if (current == total) { $button.addClass('off') }
    else { $button.removeClass('off'); }
    if (current != 0) { $button.siblings('.up').removeClass('off'); }
    return false;
  },
  
  switch_community_tabs: function(event) {
    var $link = $(event.currentTarget);
    if ($link.hasClass('active')) { return false; }
    
    var $section = $('#community .module #' + $link.attr('show'));
    $section.siblings().hide();
    $section.show();
    $link.addClass('active').siblings().removeClass('active');
    
    return false;
  }
});

window.DiscussionView = Backbone.View.extend({
	
	el: $('#discussion'),
	
	events: {
		'click #discussion-inner':  'enter_discussion_experience',
		'click #discussion-fader':  'exit_discussion_experience',
		'click .show-all-topics':   'list_topics',
		'click #topics ul a':       'goto_topic',
		'click #new-topic-link':    'show_topic_form',
		'submit #new_discussion':   'post_new_discussion'
	},
	
	initialize: function() {
	  this.on = false;
	  
	  _.bindAll(this, 'list_topics', 'enter_discussion_experience', 'exit_discussion_experience');
	  
	  $('#discussion .discussion-reply-field').autoResize({minHeight:15, extraSpace:6});
	  $('#discussion #new_discussion #discussion_body').autoResize({ minHeight: 25, extraSpace: 6 });
  },
  
  enter_discussion_experience: function() {
    $('#discussion').removeClass('off').addClass('on');
    this.on = true;
  },
  
  exit_discussion_experience: function() {
    $('#discussion').removeClass('on').addClass('off');
    this.on = false;
  },
  
  list_topics: function() {
    if (!this.on) { this.enter_discussion_experience(); }
    $('#discussion-inner').css('margin-left', 0);
    return false;
  },
  
  goto_topic: function(event) {
    if (!this.on) { this.enter_discussion_experience(); }
    var $topic = $(event.currentTarget);
    var topic_id = $topic.attr('topic');
    var $details = $('#topic');
    $details.addClass('loading');
    $('#discussion-inner').css('margin-left', -980);
    $.get('/discussions/' + topic_id, function(results) {
      $details.html(results).removeClass('loading');
    });
    return false;
  },
  
  show_topic_form: function() {
    if ($('#new_discussion').is(':visible')) { return false; }
    if (!this.on) { this.enter_discussion_experience(); }
    $('#new_discussion').show();
    return false;
  },
  
  post_new_discussion: function(event) {
    event.preventDefault();
    var $form = $('#new_discussion');
    
    var topic = $form.find('#discussion_topic').val();
    var body = $form.find('#discussion_body').val();
    if ($.trim(body) == '') { return; }
    var token = $form.find('input[name="authenticity_token"]').val();
    
    $form.find('#discussion_topic, #discussion_body').val('');
    $.post('/discussions', {
      'discussion[topic]': topic,
      'discussion[body]': body,
      'authenticity_token': token
    }, function(html) {
      $form.hide();
      $form.siblings('ul').prepend(html);
      Comments.increment_comment_count($form.parent().siblings('.toggle-comments'));
    });
    
    return false;
  }
  
});

window.Profile = new ProfileView;
window.Discussion = new DiscussionView;