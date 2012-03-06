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
    $.get('/projects', {page: current_page, category: current_category}, function(result) {
      $('#projects ul').append(result);
      reset_height();
      check_for_no_more(result);
      mpq.track('Scrolled Home Page Projects', {page: current_page, category: current_category});
    });
  }
}
$(document).scroll(monitor_scrolling);
$(window).resize(function() {
  visible_height = document.documentElement.clientHeight;
});

function reset_height() {
  total_height = document.body.offsetHeight;
}
function check_for_no_more(result) {
  if ($.trim(result) == '') {
    $('#projects-loading').addClass('done').html('No more content');
    stop_scrolling = true;
  }
}

// Filtering
var current_category = undefined;

$('#filter a').click(function() {
  var $link = $(this);
  $link.addClass('selected').siblings().removeClass('selected');
  
  current_category = $link.text();
  if (current_category == 'All') { current_category = ''; }

  $('#people').addClass('loading');
  $.get('/people?category=' + current_category, function(result) {
    $('#people ul').html(result);
    $('#people').removeClass('loading');
    reset_height();
  });

  $('#projects').addClass('loading');
  $('#projects-loading').hide();
  $.get('/projects?category=' + current_category, function(result) {
    $('#projects ul').html(result);
    $('#projects').removeClass('loading');
    check_for_no_more(result);
    $('#projects-loading').show();
    reset_height();
  });

  return false;
});