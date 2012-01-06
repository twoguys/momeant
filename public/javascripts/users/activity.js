$(function() {
  
  window.ActivityView = Backbone.View.extend({
		el: $('#activity'),
		
		events: {
			'click #load-more-activity':              'load_more'
		},
		
		initialize: function() {
			this.filter = 'all';
			this.user_id = undefined;
			this.page = 1;
			this.setup_custom_dropdown();
		},
		
		setup_custom_dropdown: function() {
		  $('#activity-filter select').dropkick({
		    width:230,
		    change: this.filter_activity
		  });
		},
		
		filter_activity: function(filter) {
		  Activity.filter = filter;
		  
		  Activity.show_loading();
		  $('#load-more-activity').hide();
		  $.ajax({
		    url: activity_url,
		    data: {filter: filter},
		    success: Activity.update_list
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
	
	// load the sidebar curated data if a user is logged in
  if (typeof friends_activity_url != "undefined") {
	  $.get(friends_activity_url, function(data) {
	    var html = $.trim(data);
	    if (html != "") {
	      $('#curated-data').append(data).slideDown();
	    }
	  });
  }

	if (typeof similar_to_what_ive_rewarded_url != "undefined") {
	  $.get(similar_to_what_ive_rewarded_url, function(data) {
	    var html = $.trim(data);
	    if (html != "") {
	      $('#similarly-to-what-ive-rewarded').append(data).slideDown();
	    }
	  });
	}

	if (typeof nearby_content_url != "undefined") {
	  $.get(nearby_content_url, function(data) {
	    var html = $.trim(data);
	    if (html != "") {
	      $('#nearby-content').append(data).slideDown();
	    }
	  });
	}

});