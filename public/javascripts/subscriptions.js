window.SubscriptionsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
		'click #vertical-people a': 'filter_person',
		'keypress .comment-box': 'monitor_comment_keypress'
	},
	
	initialize: function() {
	  this.auto_resize_comment_boxes();
  },
  
  auto_resize_comment_boxes: function() {
    $('.comment-box').autoResize({minHeight:15, extraSpace:6});
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
  },
  
  monitor_comment_keypress: function(event) {
    var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
	  switch (key) {
	    case 13: // enter key
	      event.preventDefault();
	      Subscriptions.submit_comment(event);
	      return;
    }
    
    
  },
  
  submit_comment: function(event) {
    var $form = $(event.currentTarget).parent();
    
    var commentable_type = $form.find('#comment_commentable_type').val();
    var commentable_id = $form.find('#comment_commentable_id').val();
    var comment = $form.find('#comment_comment').val();
    if ($.trim(comment) == '') { return; }
    var token = $form.find('input[name="authenticity_token"]').val();
    
    $form.find('#comment_comment').val('');
    $.post('/users/' + user_id + '/comments', {
      'comment[commentable_type]': commentable_type,
      'comment[commentable_id]': commentable_id,
      'comment[comment]': comment,
      'authenticity_token': token
    }, function(html) {
      $form.siblings('ul.comment-list').append(html);
    });
  }
  
});

window.Subscriptions = new SubscriptionsView;