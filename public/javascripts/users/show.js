$(function() {
  $('#tabs a').click(function() {
    var $link = $(this);
    if ($link.hasClass('selected')) { return false; }
    
    $link.addClass('selected').siblings().removeClass('selected');
    var $text = $('#tabs #text .' + $link.text().toLowerCase());
    $text.removeClass('hidden').siblings().addClass('hidden');
    
    return false;
  });
});