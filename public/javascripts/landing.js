$(function() {
  
  window.BookView = Backbone.View.extend({
		
		el: $('#main'),
		
		events: {
			'click #page2 a': 'view_creators',
			'click #filter a': 'load_people'
		},
		
		initialize: function() {
		  this.book = $('#book');
			this.book.booklet({
			  manual: false,
			  width: '100%',
			  height: '100%'
			});
			
			this.current_category = undefined;
		},
		
		view_creators: function() {
		  Book.book.booklet('next');
		  return false;
		},
		
		load_people: function(event) {
		  var $link = $(event.currentTarget);
      $link.addClass('selected').parent().siblings().find('a').removeClass('selected');

      Book.current_category = $link.text();
      if (Book.current_category == 'All') { Book.current_category = ''; }

      var $people = $('#people');
      if (!$people.is(':visible')) { $people.show(); }
      $people.addClass('loading');
      $.get('/people?category=' + Book.current_category, function(result) {
        $('#people ul').html(result);
        $people.removeClass('loading');
      });

      return false;
		}
		
	});
	
	window.Book = new BookView;
	
});