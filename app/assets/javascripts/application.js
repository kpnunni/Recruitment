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
//= require prototype.js
//= require bootstrap.js
//= require_tree .
      jQuery.noConflict(true);
        jQuery(document).ready(function() {
         jQuery('#datePicker1').datepicker();
         jQuery('#schedule_sh_date').datepicker({dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, minDate: "-0d"});
         jQuery('#search_from').datepicker({ changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"});
         jQuery('#search_to').datepicker({changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d" });
       });
    function show_submitting()
    {
        document.getElementById('submitting').show();
    }
    function schedule_now(id){
        jQuery('#'+id).dialog({ modal: true, title: 'Scheduling',width: 460 } );
    }
    function show_box(no){
        jQuery("#"+no+"").dialog({width: 650,position: {   at: " bottom" }  });
    }
    function open_instruction(no){
        jQuery("#"+no+"").dialog({modal: true,width: 800});
    }
       jQuery('.calendar').live('click', function() {
         jQuery(this).datepicker({showOn:'focus', changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"}).focus();
      });