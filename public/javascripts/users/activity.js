$(function() {
  
  window.ActivityFilterView = Backbone.View.extend({
		el: $('#activity-filter'),
		
		events: {
			'click #types a':        'select_filter'
		},
		
		initialize: function() {
			this.current_filter = 'all';
			this.user_id = undefined;
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
		  this.current_filter = filter;
		  
		  this.show_loading();
		  $.get('/users/' + user_id + '/activity', {filter: filter}, this.update_list);
		},
		
		update_list: function(html) {
  	  if ($.trim(html) == '') { html = '<li class="none">No activity yet.</li>'; }
		  $('#activity').html(html);
		  ActivityFilter.hide_loading();
		},
		
		show_loading: function() {
  	  $('#activity').fadeOut(200);
		  $('#activity-loading').fadeIn(200);
		},
		
		hide_loading: function() {
		  $('#activity-loading').fadeOut(200);
		  $('#activity').fadeIn(200);
		}
	});
	
	window.ActivityFilter = new ActivityFilterView;

});