var stats_browser;
var story_stats_browser = function() {
	
	this.initialize = function() {
		$('#stories li').click(handle_story_click);
	};
	
	var handle_story_click = function() {
		$(this).addClass('selected').siblings().removeClass('selected');
		var story_id = $(this).attr('story_id');
		if (story_id) {
			eval('var story_rewards = story_' + story_id + '_rewards');
			eval('var story_views = story_' + story_id + '_views');
			log(story_views);
			chart.series[0].data = story_views;
			//chart.series[1].data = story_rewards;
			chart.drawSeries({},0);
			//chart.drawSeries({},1);
		}
		return false;
	};
};

$(document).ready(function() {
	stats_browser = new story_stats_browser();
	stats_browser.initialize();
});