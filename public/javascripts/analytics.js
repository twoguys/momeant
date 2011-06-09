var stats_browser;
var story_stats_browser = function() {
	
	this.initialize = function() {
		$('#stories li').click(handle_story_click);
		setup_sparkline_charts();
	};
	
	var handle_story_click = function() {
		$(this).addClass('selected').siblings().removeClass('selected');
		var story_title = $(this).find('.title-and-date h2').text();
		$('#title').text(story_title);
		var story_id = $(this).attr('story_id');
		if (story_id) {
			eval('var story_rewards = story_' + story_id + '_rewards');
			eval('var story_views = story_' + story_id + '_views');
			chart.series[0].data = story_views;
			chart.series[1].data = story_rewards;
			chart.drawSeries({},0);
			chart.drawSeries({},1);
		}
		return false;
	};
	
	var setup_sparkline_charts = function() {
		var options = {type:'bar', barColor:'#ccc', height:'20px'};
		$('#profile-views .sparkline').sparkline(profile_views, options);
		$('#story-previews .sparkline').sparkline(story_previews, options);
	};
};

$(document).ready(function() {
	stats_browser = new story_stats_browser();
	stats_browser.initialize();
});