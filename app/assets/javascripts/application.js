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

      var jQuery2 = jQuery.noConflict();

//tool tip to animated title
        jQuery2(document ).tooltip({
//            tooltipClass: "clock",
            content: function() {
                var element = jQuery2(this);
                if (element.hasClass("cdate")) {
                    var text = element.text();
                    return date_init(element);
                }
            },
            show: {
                effect: "slideDown",delay: 250
            },
            hide: {
             //   effect: "explode", delay: 100
            },
            track: true
        });

        jQuery2(document).ready(function() {


            jQuery2("#rs7").hide();
            jQuery2("#rs30").hide();
            jQuery2("#sh7").hide();
            jQuery2("#sh30").hide();
         jQuery2('#datePicker1').datepicker();
         jQuery2('#schedule_sh_date').datetimepicker({dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, minDate: 0,timeFormat: "hh:mm tt", hourGrid: 6,minuteGrid: 10,
             beforeShow: function(input, inst)
                {
                    inst.dpDiv.css({marginTop: '0px'});
                }
         });
         jQuery2('#search_from').datepicker({ changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"});
         jQuery2('#search_to').datepicker({changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d" });

                jQuery2('td input[type="checkbox"]').click(function(){
                    if (jQuery2(this).is(':checked')){
                          jQuery2(this).parent().addClass('highlighted');
                          jQuery2(this).parent().siblings().addClass('highlighted');
                    } else if(jQuery2(this).parent().is('.highlighted')) {
                         jQuery2(this).parent().removeClass('highlighted');
                         jQuery2(this).parent().siblings().removeClass('highlighted');
                    }
                });
        });
    function show_submitting()
    {
        document.getElementById('submitting').show();
    }
    function schedule_now(id){
        jQuery2('#'+id).dialog({ modal: true, title: 'Scheduling',width: 460 } );
    }
    function show_box(no){
        jQuery2("#"+no+"").dialog({width: 800  });
    }
    function open_instruction(no){
        jQuery2("#"+no+"").dialog({modal: true,width: 800});
    }
       jQuery2('.calendar').live('click', function() {
         jQuery2(this).datepicker({showOn:'focus', changeMonth: true ,changeYear: true,dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, maxDate: "+0d"}).focus();
      });
       jQuery2('.c_calendar').live('click', function() {
         jQuery2(this).datetimepicker({showOn:'focus', dateFormat: "dd-mm-yy", hideIfNoPrevNext: true, minDate: 0,timeFormat: "hh:mm tt", hourGrid: 6,minuteGrid: 10,
                beforeShow: function(input, inst)
                {
                    inst.dpDiv.css({marginTop: '250px'});
                }
         }).focus();
      });

    function date_init(element){
        var content = element.html();
        var min = parseInt(content.substr(-4, 2));
        var hr = parseInt(content.substr(-7, 2));
        var date = content.split(" ").slice(0,2).join(" ");
//        alert(1);
        return show_clock(hr, min, date);
    }

function show_clock(h, m, dt){
        var hours   = h;
        var mins    = m;
        var date = dt;
        var hdegree = hours * 30 + (mins / 2);
//        var hrotate = "rotate(" + hdegree + "deg)";

//        jQuery2(obj).find(".hour").css({"-moz-transform" : hrotate, "-webkit-transform" : hrotate});

        var mdegree = mins * 6;
//        var mrotate = "rotate(" + mdegree + "deg)";

//        jQuery2(obj).find(".min").css({"-moz-transform" : mrotate, "-webkit-transform" : mrotate});
//        jQuery2(obj).find(".date").html(date);


    return "<div class=\"clock\">\
                    <li style=\"transform: rotate(" + hdegree + "deg);\" class=\"hour\"></li>\
                    <li style=\"transform: rotate(" + mdegree + "deg);\" class=\"min\"></li>\
                    <li class=\"date\">" + date + "</li>\
                </div>";

    }








