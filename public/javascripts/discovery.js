Array.prototype.remove= function(){
  var what, a= arguments, L= a.length, ax;
  while(L && this.length){
    what= a[--L];
    while((ax= this.indexOf(what))!= -1){
      this.splice(ax, 1);
    }
  }
  return this;
}

var Discovery = {};

Discovery.get_parameter_by_name = function(name) {
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.search);
  if (results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
};

Discovery.update_parameter = function(key, value) {
  key = escape(key); value = escape(value);
  var s = window.location.search;
  var kvp = key + "=" + value;
  var r = new RegExp("(&|\\?)" + key + "=[^\&]*");
  s = s.replace(r, "$1" + kvp);
  if (!RegExp.$1) { s += (s.length > 0 ? '&' : '?') + kvp; }
  window.location.search = s;
};

Discovery.apply_category = function(category) {
  var current_categories = Discovery.get_parameter_by_name('category');
  if (current_categories != '') {
    current_categories = current_categories.split('|');
  } else {
    current_categories = [];
  }  
  if ($.inArray(category, current_categories) >= 0) {
    current_categories.remove(category);
  } else {
    current_categories.push(category);
  }
  var new_categories = current_categories.join('|');
  Discovery.update_parameter('category', new_categories);
};

Discovery.apply_sort = function(sort) {
  var current_sort = Discovery.get_parameter_by_name('sort');
  
}

$('#categories a').click(function() {
  var $link = $(this);
  var category = $link.text();
  Discovery.apply_category(category);
  $link.toggleClass('active');
  return false;
});

$('#sort a').click(function() {
  var $link = $(this);
  if ($link.hasClass('active')) { return false; }
  var sort = $link.text();
  Discovery.update_parameter('sort', sort);
  $link.addClass('active').siblings().removeClass('active');
  return false;
});