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
//= require jquery.js
//= require jquery_ujs.js
 //= require_tree .

//      jQuery.noConflict(true);

//tool tip to animated title
        jQuery(document ).tooltip({
            show: {
                effect: "slideDown",delay: 250
            },
            hide: {
             //   effect: "explode", delay: 100
            },
            track: true
        });

        jQuery(document).ready(function() {


            jQuery("#rs7").hide();
            jQuery("#rs30").hide();
            jQuery("#sh7").hide();
            jQuery("#sh30").hide();
         jQuery('#datePicker1').datepicker();
         jQuery('#schedule_sh_date').datetimepicker({dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, minDate: 0,timeFormat: "hh:mm tt", hourGrid: 6,minuteGrid: 10,
             beforeShow: function(input, inst)
                {
                    inst.dpDiv.css({marginTop: '50px'});
                }
         });
         jQuery('#search_from').datepicker({ changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"});
         jQuery('#search_to').datepicker({changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d" });

                jQuery('td input[type="checkbox"]').click(function(){
                    if (jQuery(this).is(':checked')){
                          jQuery(this).parent().addClass('highlighted');
                          jQuery(this).parent().siblings().addClass('highlighted');
                    } else if(jQuery(this).parent().is('.highlighted')) {
                         jQuery(this).parent().removeClass('highlighted');
                         jQuery(this).parent().siblings().removeClass('highlighted');
                    }
                });
        });
    function show_submitting()
    {
        document.getElementById('submitting').show();
    }
    function schedule_now(id){
        jQuery('#'+id).dialog({ modal: true, title: 'Scheduling',width: 460 } );
    }
    function show_box(no){
        jQuery("#"+no+"").dialog({width: 800  });
    }
    function open_instruction(no){
        jQuery("#"+no+"").dialog({modal: true,width: 800});
    }
       jQuery('.calendar').live('click', function() {
         jQuery(this).datepicker({showOn:'focus', changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"}).focus();
      });
       jQuery('.c_calendar').live('click', function() {
         jQuery(this).datetimepicker({showOn:'focus', dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, minDate: 0,timeFormat: "hh:mm tt", hourGrid: 6,minuteGrid: 10,
                beforeShow: function(input, inst)
                {
                    inst.dpDiv.css({marginTop: '250px'});
                }
         }).focus();
      });










