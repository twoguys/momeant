$(function() {
  
  window.ActivityView = Backbone.View.extend({
		el: $('#activity'),
		
		events: {
			'click #activity-filter #types a':        'select_filter',
			'click #load-more-activity':              'load_more'
		},
		
		initialize: function() {
			this.filter = 'all';
			this.user_id = undefined;
			this.page = 1;
		},
		
		select_filter: function(e) {
		  var $link = $(e.currentTarget);
		  var $list_item = $link.parent();
		  
		  if ($list_item.hasClass('selected')) { return false; }
		  $list_item.addClass('selected').siblings().removeClass('selected');
		  this.filter_activity($link.attr('filter'));
		  
		  return false;
		},
		
		filter_activity: function(filter) {
		  this.filter = filter;
		  
		  this.show_loading();
		  $('#load-more-activity').hide();
		  $.ajax({
		    url: activity_url,
		    data: {filter: filter},
		    success: this.update_list
      });
		},
		
		update_list: function(html) {
  	  if ($.trim(html) == '') { html = '<li class="none">No activity yet.</li>'; }
		  $('#activity-list').html(html);
		  Activity.hide_loading();
		  
		  var number_of_activity = $('#activity-list').children().length;
		  if (number_of_activity < 10) {
		    $('#load-more-activity').hide();
		  } else {
		    $('#load-more-activity').show();
		  }
		},
		
		add_to_list: function(html) {
		  if ($.trim(html) == '') {
		    $('#load-more-activity').hide();
		  } else {
		    $('#activity-list').append(html);
		  }
		},
		
		show_loading: function() {
  	  $('#activity-list').fadeOut(200);
		  $('#activity-loading').fadeIn(200);
		},
		
		hide_loading: function() {
		  $('#activity-loading').fadeOut(200);
		  $('#activity-list').fadeIn(200);
		},
		
		load_more: function(event) {
		  var $button = $(event.currentTarget);
		  this.page = this.page + 1;
		  
		  $button.addClass('loading');
		  $.get(activity_url, {filter: this.filter, page: this.page}, function(html) {
		    Activity.add_to_list(html);
		    $button.removeClass('loading');
		  });
		  
		  return false;
		}
	});
	
	window.Activity = new ActivityView;

});