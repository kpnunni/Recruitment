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

//= require jquery_ujs
//= require bootstrap
//= require prototype
//= require_tree .
//= require jquery
var a,b
// set the url of the page to show in the popup

var urlPop = "/homes/index"

// set the title of the page

var title =  "Suyati recruitment test"

// set this to true if the popup should close
// upon leaving the launching page; else, false

var autoclose = false

// ============================
// do not edit below this line
// ============================

var beIE = document.all?true:false

function openFrameless(){
    if (beIE){
        NFW = window.open(urlPop,"channelmode=1, fullscreen=1",true)


    } else {
            NFW = window.open(urlPop,"channelmode=1, fullscreen=1,location=no",true)
    }
    NFW.focus();
    if (autoclose){
        window.onunload = function(){NFW.close()}
    }
}


