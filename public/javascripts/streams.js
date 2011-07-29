var streamer;
var stream_handler = function() {
	this.url = '';
	this.page = 1;
	
	this.initialize = function() {
		url = $('a#load-more').attr('href');
		$('a#load-more').click(streamer.load_next_set);
	};
	
	this.load_next_set = function() {
		streamer.page += 1;
		$.get(streamer.url, 
			{
				page: streamer.page,
				js: 1
			},
			function(data) {
				streamer.render_set(data);
			}
		);
		return false;
	};
	
	this.render_set = function(html) {
		$('#hidden-reward-appender').append(html);
		var $newElems = $('#hidden-reward-appender li.reward');
		$('ul.reward-thumbnails').append($newElems).masonry('appended',$newElems);
		$('#hidden-reward-appender').html('');
		if ($newElems.length == 0) {
			$('a#load-more').hide();
		}
	};
};

$(document).ready(function() {
	streamer = new stream_handler();
	streamer.initialize();
});