window.DiscoveryView = Backbone.View.extend({
	
	el: $('body'),
	
	events: {
		//'click #creators .pagination a':    'paginate_creators',
		//'click #work-browser .list a':      'paginate_content'
	},
	
	initialize: function() {
	  this.handle_filter_dropdown();
  },
  
  handle_filter_dropdown: function() {
    $('html').click(function() {
      var $filters = $('#filters ul');
      if ($filters.is(':visible')) { $filters.hide(); }
    });

    $('#current-filter').click(function(event) {
      $('#filters ul').toggle();
      event.stopPropagation();
    });

    $('#filters ul').click(function(event) {
      event.stopPropagation();
    });

    $('#filters ul a').click(function() {
      var $link = $(this);
      $('#current-filter').text($link.text());
      $('#filters ul').toggle();
    });
  },
  
  paginate_creators: function(event) {
    var $link = $(event.currentTarget);
    var text = $link.text();
    if (text.indexOf('Next') == 0) {
      Discovery.creator_page += 1;
    } else if (text.indexOf('Prev') >= 0) {
      Discovery.creator_page -= 1;
    } else {
      Discovery.creator_page = parseInt(text);
    }
    Discovery.paginate('creators', Discovery.creator_page);
    return false;
  },
  
  paginate_content: function(event) {
    var $link = $(event.currentTarget);
    var text = $link.text();
    if (text.indexOf('Next') == 0) {
      Discovery.content_page += 1;
    } else if (text.indexOf('Prev') >= 0) {
      Discovery.content_page -= 1;
    } else {
      Discovery.content_page = parseInt(text);
    }
    Discovery.paginate('content', Discovery.content_page);
    return false;
  },
  
  paginate: function(what, number) {
    $.get('/discovery?filter=' + Discovery.filter + '&' + what + '_page=' + number, function(results) {
      $('#' + what).html(results);
    });
  }
  
});

window.Discovery = new DiscoveryView;