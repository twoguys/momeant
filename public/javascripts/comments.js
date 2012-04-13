window.CommentsView = Backbone.View.extend({
  
  el: $('body'),
	
	events: {
  	'click a.toggle-comments': 'toggle_comments',
		'keypress .comment-box': 'monitor_comment_keypress'
	},
	
	initialize: function() {
	  this.auto_resize_comment_boxes();
  },

  toggle_comments: function(event) {
    var $link = $(event.currentTarget);
    var $comments = $link.siblings('.insides');
    if ($link.hasClass('open')) {
      $comments.slideUp(100);
      $link.removeClass('open');
    } else {
      $comments.slideDown(100);
      $link.addClass('open');
    }
    return false;
  },
  
  auto_resize_comment_boxes: function() {
    $('.comment-box').autoResize({minHeight:15, extraSpace:6});
  },
  
  monitor_comment_keypress: function(event) {
    var key = event.charCode ? event.charCode : event.keyCode ? event.keyCode : 0;
	  switch (key) {
	    case 13: // enter key
	      event.preventDefault();
	      Comments.submit_comment(event);
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
      Comments.increment_comment_count($form.parent().siblings('.toggle-comments'));
    });
  },
  
  increment_comment_count: function($link) {
    var $amount = $link.find('.amount');
    var $text = $link.find('.text');
    var amount = parseInt($amount.text()) + 1;
    $amount.text(amount);
    if (amount == 1) {
      $text.text('comment');
    } else {
      $text.text('comments');
    }
  }
  
});

window.Comments = new CommentsView;