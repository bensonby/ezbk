// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
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

$('.input-debit-amount').live('change', function(event){
  if($(this).val() != "") $(this).addClass("manual-input");
  else $(this).removeClass("manual-input");
  $(".input-debit-amount:not(.manual-input)").each(function(index, e){
    $(e).val("");
  });

  var total = 0.0;
  $(".input-debit-amount.manual-input").each(function(i,e){ total+=parseFloat($(e).val()); });
  if(total.toFixed(2) == "0.00") return ;
  if($(".input-debit-amount:not(.manual-input)").length == 0){
    var add_transaction_entry_element = $('#add-transaction-entry');
    var scripts = add_transaction_entry_element.attr('onclick');
    scripts = scripts.substr(0, scripts.length-13);
    scripts = scripts.replace(/add_fields\(this/, "add_fields($('#add-transaction-entry')");
    eval(scripts);
  }
  $(".input-debit-amount:not(.manual-input):first").val(-total.toFixed(2));
});

function highlight_account_in_transactions(account_name){
  $('#account-transactions-container a').
filter(function(){ return $(this).html() == account_name; }).
each(function(index, e){
    $(e).closest("tr").addClass('current-account');
  });
}
