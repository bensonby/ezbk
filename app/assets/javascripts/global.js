function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  var container_tag = $(link).attr('container-tag');
  if(container_tag != null){
    var container = $(link).closest(container_tag);
  }else{
    var container = $(link).parent();
  }
  container.before(content.replace(regexp, new_id));
}

function show_help(){
  $('#help').show();
}
function hide_help(){
  $('#help').hide();
}
