// Infinite scrolling

var total_height, current_scroll, visible_height, current_page, stop_scrolling;
total_height = document.body.offsetHeight;
visible_height = document.documentElement.clientHeight;
current_page = 1;
stop_scrolling = false;
function monitor_scrolling() {
  if (stop_scrolling) { return; }

  if (document.documentElement.scrollTop) { current_scroll = document.documentElement.scrollTop; }
  else { current_scroll = document.body.scrollTop; }
  
  if (total_height <= current_scroll + visible_height) {
    current_page += 1;
    $.get('/projects', {page: current_page}, function(result) {
      $('#projects ul').append(result);
      total_height = document.body.offsetHeight;
      mpq.track('Scrolled Home Page Projects', {page: current_page});
      
      if ($.trim(result) == '') {
        $('#projects-loading').addClass('done').html('No more content');
        stop_scrolling = true;
      }
    });
  }
}  
$(document).scroll(monitor_scrolling);
$(window).resize(function() {
  visible_height = document.documentElement.clientHeight;
});