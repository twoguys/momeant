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