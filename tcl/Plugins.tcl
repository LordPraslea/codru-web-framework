##########################################
# Bootstrap and jQuery plugin's
##########################################
#	 LostMVC -	 http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014 United Brain Power <info@unitedbrainpower.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the imfplied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#TODO view/edit data via json if javascript is on, simple if not..
#TODO  bulk aactions.. 

	##########################################
	#  detailview 
	# 		details about one view by just giving the name 
	# 		use this instead of generating it//
	##########################################
	 
bhtml public method detailView {{-table 1} --  model columns {specials ""}} {
	#Specials contains (for now) a list of column name and function
	#to run for that column name so we return the correct text..
	#TODO specials can be functions OR simple literals..
	##TODO in the future extract "col" from "columns" based on specials..
	#so we don't verify if col exists in specials 1000 times
	#
	#TODO specials for gridview!
	foreach col $columns {
		lappend tableheaders [$model getAlias $col]  
		if {$col in $specials} {
			set fun  [lindex $specials [lsearch $specials $col]+1]	
			lappend tabledata [$model $fun [$model get $col]]
		} else {
			lappend tabledata [$model get $col]
		}
	}
	if {$table} {
	
		set return  [my tableHorizontal -bordered 1 -striped 1 -hover 1 -rpr 0  $tableheaders $tabledata]
	}
	return $return
}	
	
	##########################################
	# Datetimepicker addon 
	##########################################

bhtml public method datetimepicker {{-class ""} {-htmlOptions ""} {-format "YYYY-MM-DD HH:mm:ss"} {-id ""} {-moreSettings ""} {-placeholder ""} 
   {-popover ""} {-tooltip ""}  -- name {value ""}} {
	#TODO more settings

	if {![my existsPlugin datetimepicker]} {
		my addPlugin datetimepicker { 
			css "/css/bootstrap-datetimepicker.min.css"
			css-min "/css/bootstrap-datetimepicker.min.css"
			js  { "/js/moment.min.js" "/js/bootstrap-datetimepicker.min.js" }
			js-min  { "/js/moment.min.js" "/js/bootstrap-datetimepicker.min.js" }

		}
	}

	my js [format {
		$('#%s').datetimepicker({
			showToday:true,
			format: '%s',
			%s
		});
		//alert("Oooh yeah!");
	} $name $format $moreSettings ]
	#This works
	#set input [my input -htmlOptions [list data-provide "datepicker"] -id $name $name $value]
	
	set input [my input -placeholder $placeholder -id $name $name $value]
	set span [my htmltag -htmlOptions  [list class input-group-addon] span [my fa fa-calendar] ]

	dict set htmlOptions class "input-group date"
	set div [my htmltag -htmlOptions $htmlOptions div "$input $span"]
	return $div
}
	##########################################
	# Datepicker addon 
	##########################################

bhtml public method datepicker {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""}  -- name {value ""}} {

	if {![my existsPlugin datepicker]} {
		my addPlugin datepicker { 
			css "/css/datepicker3.css"
			css-min "/css/datepicker3.min.css"
			js "/js/bootstrap-datepicker.js"
			js-min "/js/bootstrap-datepicker.min.js"
		}
	}

	my js [format {
		$('#%s').datepicker({
			format: "yyyy-mm-dd",
			weekStart: 1,
			multidate: false,
			calendarWeeks: true,
			todayHighlight: true
		});
		//alert("Oooh yeah!");
	} $name ]
	#This works
	#set input [my input -htmlOptions [list data-provide "datepicker"] -id $name $name $value]
	set input [my input -placeholder $placeholder -id $name $name $value]
	set span [my htmltag -htmlOptions  [list class input-group-addon] span [my fa fa-calendar] ]

	set div [my htmltag -htmlOptions [list class [list input-group $class]] div "$input $span"]
	#set div [my htmltag div "$input $span"]
	return $div ;#$input
}
##########################################
# X-editable 
# url:  http://vitalets.github.io/x-editable/
# In place editing with jquery and bootstrap
##########################################

#TODO make it have more options..
bhtml public method editable {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""}  -- name {value ""}} {
	if {![my existsPlugin editable]} {
		my addPlugin editable { 
			css "/css/bootstrap-editable.css"
			css-min "/css/bootstrap-editable.min.css"
			js "/js/bootstrap-editable.js"
			js-min "/js/bootstrap-editable.min.js"
		}
	}

	my js [format { $('#%s').editable(); } $name ]
	set input [my a -id $name $value]
	return $input
}

##########################################
# Select2 (3.4.8) 
# url: http://ivaynberg.github.io/select2/  
# Replacement for select boxes, supports searching, remote data sets.. infinite scrolling of results.. etc
##########################################

#TODO make it have more options..
bhtml public method select2 {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""} {-options ""}   -- name {value ""} {tags ""}} {
	#minimumInputLength: 2,
	#
	if {0} {
	query: function (query) {
		var data = {results: []};
		 data:[{id:0,text:'enhancement'},{id:1,text:'bug'},{id:2,text:'duplicate'},{id:3,text:'invalid'},{id:4,text:'wontfix'}]
	}
	}
	set plugin select2
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css { "/css/select2.css" "/css/select2-bootstrap.css"}
			css-min { "/css/select2.css" "/css/select2-bootstrap.css"}
			js "/js/select2.js"
			js-min "/js/select2.min.js"
		}
	}

	my js [format { $('#%s').select2({
		tags: [%s],
		multiple: true,
		tokenSeparators: [',','\t','\n',';'],
		width: 'resolve',
		%s
	}); } $name $tags $options ]
	set input [my input -class [concat "form-control " $class] -id $name -placeholder $placeholder $name $value]
	return $input
}

#This makes everything a little bit beautifuller..
##########################################
# PretyCheckable) 
# url: http://arthurgouveia.com/prettyCheckable/
# a beautiful checkbox
##########################################

bhtml public method prettycheckable {{-class ""} {-id ""} {-placeholder ""}   -- name data } {
#TODO implement more options
	set plugin prettycheckable
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css  "/css/prettyCheckable.css" 
			css-min  "/css/prettyCheckable.css" 
			js "/js/prettyCheckable.min.js"
			js-min "/js/prettyCheckable.min.js"
		}
	}

	my js [format { $('#%s').prettyCheckable({
		color: 'red',	
	}); } $name ]
	set input [my input -type checkbox -id $name $name $data]
	return $input
}


##########################################
# Bootstrap toggle! 
# url:  http://minhur.github.io/bootstrap-toggle/
# a beautiful toggle button
##########################################

#TODO make it have more options.. like primary type etc..
#Differfent types of buttons for on and off..etc
#not working yet.. port from earlier ersion
#TODO icon class for on or off.. otherwise size keeps growing..
bhtml public method toggle {{-class ""} {-id ""} {-placeholder ""} {-ontype "primary"} {-offtype "default"} \
			   {-onicon ""} {-officon ""} {-size ""} {-round 0} {-data 1}   -- on off name } {
	#This has some modifications from the original
	#The .js file is modified: alternating values 1 or 0

	set plugin toggle
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css  "/css/bootstrap-toggle.css" 
			css-min  "/css/bootstrap-toggle.min.css" 
			js "/js/bootstrap-toggle.js"
			js-min "/js/bootstrap-toggle.min.js"
		}
	}
	if {$data == ""} { set data 1 }

	if {$data} { set toggleon on } else { set toggleon off }

	set onlen [string length $on]
	set offlen [string length $off]
	if {$onicon != ""} { incr onlen 3  }
	if {$officon != ""} { incr offlen 3 }

 		if {$onlen>$offlen} {
			set thesize $onlen
		} else { set thesize $offlen }
		switch $size {
			mini { set size "btn-xs" ; set fontsize 4 }
			small { set size "btn-sm"  ; set fontsize 5.5 }
			large { set size "btn-lg" ; set fontsize 10 }
			default { set fontsize 7 }
		}
		set togglesize [expr {$thesize*$fontsize+35}]

set roundclass ""
if {$round} { set roundclass ios }
#	my js [format { } $name ]
	#This works
	set on  [my label -class "toggle-on btn btn-${ontype} $size $roundclass" "$onicon $on" ]
	set off [my label -class "toggle-off btn active btn-${offtype} $size $roundclass  " "$officon $off" ]
	set span [my htmltag -htmlOptions [list class [list toggle-handle btn btn-default $size $roundclass]] span] 
	set togglegroup [my htmltag -htmlOptions [list class "toggle-group"] div "$on $off $span"] 
	set input [my input -type checkbox -class "" -htmlOptions [list checked checked ] $name $data]
	set style "min-width: ${togglesize}px;" 
#	set style ""
	set class "toggle btn btn-primary  $size $roundclass $toggleon"
	set toggle [my htmltag -htmlOptions [list id $id class $class data-toggle toggle style $style ] div "$input $togglegroup"]
	


	return $toggle
}

##########################################
# CKEditor 
# url:  http://ckeditor.com/download
#  beautiful full featured html editor for blogs.. and any other things
##########################################

#TODO make it have more options..
bhtml public method ckeditor {{-class ""} {-placeholder ""} {-id ""}  -- name {data ""} } {

	set plugin ckeditor
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/ckeditor/ckeditor.js"
			js-min "/js/ckeditor/ckeditor.js"
		}
	}
	if {$id == ""} { set id $name }

	my js [format { CKEDITOR.replace('%s')  } $name ]
	set input [my textarea -placeholder $placeholder -id $id $name $data]
	return $input
}

##########################################
# Bootstrap markdown
# http://toopay.github.io/bootstrap-markdown/
# Markdown editor for places where you want users to be able to edit but
# don't trust the input and can't be 100% sure you won't have XSS
##########################################
bhtml public method markdown {{-class ""} {-placeholder ""} {-id ""}  -- name {data ""}} {
	if {![my existsPlugin  markdown]} {
		my  addPlugin markdown {
			js { "/js/to-markdown.js" "/js/bootstrap-markdown.js"  }
			js-min { "/js/to-markdown.js"  "/js/bootstrap-markdown.min.js" }
			css "/css/bootstrap-markdown.css"
			css-min "/css/bootstrap-markdown.min.css"
		}
	}
	if {$id == ""} { set id $name }

#	my js [format { CKEDITOR.replace('%s')  } $name ]
	my js [format {$("#%s").markdown({ resize:'both',iconlibrary: 'fa'})} $name]
	set input [my textarea -options [list data-provide markdown] -placeholder $placeholder -id $id $name $data]
	return $input
}

##########################################
# Bootstrap Image Gallery 
# url:   http://blueimp.github.io/Bootstrap-Image-Gallery/
#  A beautiful image gallery..
#http://blueimp.github.io/Gallery/css/blueimp-gallery.min.css
#http://blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js
##########################################

 bhtml public method imagegallery {{-class ""} {-borders true} {-tooltip ""}  {-thumbs 0} -- name {data ""}} {

 #TODO fullscreen and other options..
	set plugin imagegallery
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css { /css/blueimp-gallery.min.css "/css/bootstrap-image-gallery.min.css" }
			css-min { /css/blueimp-gallery.min.css "/css/bootstrap-image-gallery.min.css" }
			js { /js/jquery.blueimp-gallery.min.js "/js/bootstrap-image-gallery.min.js" }
			js-min { /js/jquery.blueimp-gallery.min.js "/js/bootstrap-image-gallery.min.js" }
		}
	}

	my js [format { 
		$('#blueimp-gallery').data('useBootstrapModal', %s );
		$('#blueimp-gallery').toggleClass('blueimp-gallery-controls', !%s); 
	} $borders $borders ]

		set imgOptions [list style "width:75px;height:75px;" ]

	foreach {imgsrc desc} $data {
		#TODO disable/enable tooltip automatically
		# TODO !!! TODO 	image should be a thumbnail..
		if {$thumbs} {
			foreach {img thumb} $imgsrc { }
		} else {
			set img [set thumb $imgsrc]
		}	
		if {$tooltip != ""} { foreach {opt val} [list data-toggle tooltip data-placement top title $desc]  { dict set imgOptions $opt $val } }
		set image [my img -htmlOptions $imgOptions  -class " img-thumbnail" $thumb $desc]
		set link [my a  -htmlOptions [list data-gallery ""] -title $desc $image $img ]
		append alldata $link
	}
	set gallery [my htmltag -htmlOptions [list class $name] div $alldata]	
	set blueimp {
	<!-- The Bootstrap Image Gallery lightbox, should be a child element of the document body -->
<div id="blueimp-gallery" class="blueimp-gallery">
    <!-- The container for the modal slides -->
    <div class="slides"></div>
    <!-- Controls for the borderless lightbox -->
    <h3 class="title"></h3>
    <a class="prev"> <span style="font-size:0.6em" class="fa fa-chevron-left"> </span></a>
    <a class="next"><i style="font-size:0.6em"  class="fa fa-chevron-right"> </i></a>
    <a class="close"><i class="fa fa-times"> </i></a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
    <!-- The modal dialog, which will be used to wrap the lightbox content -->
    <div class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" aria-hidden="true">&times;</button>
                    <h4 class="modal-title"></h4>
                </div>
                <div class="modal-body next"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default pull-left prev">
                        <i class="fa fa-chevron-left"></i>
                        Previous
                    </button>
                    <button type="button" class="btn btn-primary next">
                        Next
                        <i class="fa  fa-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
	}
#	set blueimp [my htmltag -htmlOptions [list id "blueimp-gallery" class "blueimp-gallery blueimp-gallery-controls"] div $gallery]
	return "$gallery $blueimp"
}

#TODO implement pnofity or leave just this messenger?
##########################################
# HubSpot Messenger 
# # http://github.hubspot.com/messenger/
# Providing cool messages to user..
##########################################

bhtml public method messenger {{-type "info"} {-theme future} {-location "top"} {-button ""}  -- message } {
	#themes flat future block air ice	
#TODO make it have more options.. and implement all Messenger library options
#The first time you run this you give the settings..
#All subsequent runs .. go without:)
	set plugin messenger
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css "/css/messenger.css"
			css-min "/css/messenger.css"
			js "/js/messenger.js"
			js-min "/js/messenger.min.js"
		}

		set messengertheme [format "/css/messenger-theme-%s.css" $theme]
		dict lappend plugins messenger css $messengertheme
		dict lappend plugins messenger css-min $messengertheme

		switch $theme {
			flat {
				dict lappend plugins messenger js "/js/messenger-theme-flat.js" 
				dict lappend plugins messenger js-min "/js/messenger-theme-flat.js" 
			}
			future { 
				dict lappend plugins messenger js "/js/messenger-theme-future.js"
				dict lappend plugins messenger js-min "/js/messenger-theme-future.js"
			}
		}

		foreach loc $location {
			switch $loc {
				top { set theloc "messenger-on-top" }
				bottom { set theloc "messenger-on-bottom" }
				left { set theloc "messenger-on-left" }
				right { set theloc "messenger-on-right" }
				default { set theloc "messenger-on-top messenger-on-right"}
			}

			lappend messengerLocation  $theloc 
		}
		my js [format {
			Messenger.options = {
				extraClasses: 'messenger-fixed %s',
				theme: '%s',
			}  
		} $messengerLocation $theme   ]
	#	puts "This messenger has been initializated.. with $messengerLocation and $theme"
	}
#todo make this only once..for the first one? or for each one?
	my js [format {
		Messenger().post({
			message: "%s",
			type: "%s",
			showCloseButton: true,
		});	
	}  $message $type ]
	
	#TODO figure out if returning anything.. or creating buttons.. etc
	if {$button != ""} {
		#set input [my textarea -placeholder $placeholder -id $name $name $data]
	#return $input
	}

}


##########################################
# HighCharts
# http://www.highcharts.com/demo/
# Generating charts and other things.. for statistics!
# Browser side but also server side saving:)
##########################################
#TODO this needs a lot of editing to include all options..
bhtml public method highcharts {{-slideOpen 0} {-height 400} {-text ""} -- name data } {

	#themes /js/themes/gray.js etc	

	set plugin highcharts
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/highcharts.src.js"
			js-min "/js/highcharts.js"
		}

	}
	set extra ""
	set container ""
	if {$text == ""} { set text $name } 
	if {$slideOpen} {
		append container  [my  a -htmlOptions "class tglchart-${name}"  "[my  fa fa-download] Click to toggle $text" "#$name" ]<br>

		append extra [format {
			$(".tglchart-%s").click(function(e) {
				e.preventDefault();
				$('#%s').slideToggle();
			});
	 	$('#%s').hide();	
		} $name $name  $name ]	
	}
	#TODO more options.. ok for now.. since this can be sent through ajax:)
	my js [format { 
		$('#%s').highcharts({
			credits: {
				href: "http://unitedbrainpower.com",
				text: "UnitedBrainPower.com",
				enabled: true,
			},
			%s
		});	 
		%s
	} $name $data $extra ]
	
	append container [my htmltag -htmlOptions  [list id $name style "width:100%; height:${height}px; "] div "" ]
	return $container

}

##########################################
# Bootstrap ContextMenu
#  http://sydcanem.github.io/bootstrap-contextmenu/
#  This generates a context (right click) menu in a website. THis can be used to do multiple usefull things
##########################################
#Figure out if you just need ID and generate the div itself or generate it outside..
 bhtml public method contextmenu {{-slideOpen 0} {-contextOptions ""} -- contextid menuname menu {contextdata ""}} {
	
	if {![my existsPlugin contextmenu]} {
			my addPlugin contextmenu { 
			js "/js/bootstrap-contextmenu.js"
			js-min "/js/bootstrap-contextmenu.min.js"
		}
		puts "This contextmenu doesn't already exist! [dict get $plugins contextmenu]"

	}
	
 	dict set contextOptions id $contextid
	dict set contextOptions data-toggle context
	dict set contextOptions data-target #${menuname}

	my js [format { 
	    $('#%s').contextmenu();
	} $contextid ]
	if {0} {
    <div id="context" data-toggle="context" data-target="#context-menu">
    ...
    </div>
	}
#	foreach m menu {
#		-htmlOptions tabindex -1
#	}
	#TODO extend method dropdown to generate more freely...
	set ul [my makeList -htmlOptions [list class dropdown-menu role menu] $menu ] 
	set contextmenu	 [my htmltag -htmlOptions [list id $menuname] div $ul]
	set context [my htmltag -htmlOptions $contextOptions div $contextdata]
	return "$context $contextmenu"

}


##########################################
# Bootstrap Slider
#  http://seiyria.github.io/bootstrap-slider/
#  Bootstrap slider for sliding selecting.. 
###########################################
bhtml public method slider {{-slideOpen 0} {-sliderid "allslider"} {-min 0} {-max 100 }  {-step 1} --  name {value 0} {secondval ""}} {

	set plugin slider
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/bootstrap-slider.js"
			js-min "/js/bootstrap-slider.min.js"
			css "/css/bootstrap-slider.css"
			css-min "/css/bootstrap-slider.min.css"
		}

	}
	

	my js [format { 
	    $('#%s').slider({
		//	formater: function(value) {
		//		return "Current value: " + value
		//	}
		});
	} $name ]
	if {$secondval != ""} {
		set value \[${value},${secondval}\]
	}
	#ex1Slider .slider-selection {
	#	background: #BABABA;
		#}
 #for 2 selectors.. do the value [25,50]
 set slider_options [list id $name name $name data-slider-id $sliderid \
	 	data-slider-min $min data-slider-max $max data-slider-step $step data-slider-value $value ]
	set slider [my input -htmlOptions $slider_options  $name]
	return $slider 

}
##########################################
# jQuery Countdown 
#  https://github.com/Reflejo/jquery-countdown
# Beautiful countdown timer
# ###########################################
bhtml public method countdown {{-year ""} {-month ""} {-day ""} {-hour ""} -- name } {

	if {![my existsPlugin countdown]} {
		my addPlugin countdown { 
			js "/js/jquery.countdown.js"
			js-min "/js/jquery.countdown.min.js"
			css "/css/media.css"
			css-min "/css/media.css"
		}

	}
	if {$year == ""} {
		set year [clock format [clock seconds] -format %Y]	
	}
	if {$month == ""} {
	
		set month [clock format [clock seconds] -format %m]	
	}
	if {$day == ""} {
	
		set day [clock format [clock seconds] -format %d]	
	}
	if {$hour == ""} {
		set hour [clock format [clock seconds] -format %H]	
	}
	#TODO   body { background: url(../img/bg-tile.png) repeat; }
	my js [format { 
      $(function(){
        $("#%s").countdown({
          image: "img/digits.png",
          format: "dd:hh:mm:ss",
          endTime: new Date(%s, %s,%s,%s )
        });
      });
	} $name $year $month $day $hour ]
	set countdown [my tag -htmlOptions [list id $name]  div ""]
	return $countdown 

}
###############################################
#	jQuery Lazy image loading only when needed!
#	https://github.com/eisbehr-/jquery.lazy
#
###############################################
#FOR IMPLEMENTATION SEE Bhtml.tcl
##DO NOT USE THIS FUNCTION yet
#TODO needs modifying for other loading types
##Enable lazy loading for now.. if we modify html manually

bhtml public method lazyloader {args} {

	if {![my existsPlugin lazyload]} {
		my addPlugin lazyload { 
			js "/js/jquery.lazy.js"
			js-min "/js/jquery.lazy.min.js"
		}

		#delay: 5000 -> time in milliseconds that ALL images appear on page
		#combined :true -> loads on scroll and uses delay!
		##placeholder: data:image/jpg/gif base64
		# enable throttle so you  have less javascript calls!
		#enableThrottle: true
		#throttle: 250 
		:js "jQuery('img.lazy').lazy();"
		

	}

	#set img [:img {*}$args]
	#return $countdown 

}

##########################################
# Bootstrap Wizard manual
#  http://yiibooster.clevertech.biz/widgets/grouping/view/wizard.html
#  A wizard with tabs and pills 
###########################################
#TODO pager buttons next previous to go to tab..
#TODO horizontal and vertical
bhtml public method wizard { {-step 1} -- tabs } {

set wizard [my tabs -pills 1 $tabs][my pager ] 
	return $wizard 

}
#TODO download and implement
##########################################
# Bootstrap Wizard 
# http://vadimg.com/twitter-bootstrap-wizard-example/
#  A wizard with navigation and next/previous 
###########################################
bhtml public method wizard {{-step 1} -- tabs} {


	if {![my existsPlugin wizard]} {
		my addPlugin wizard { 
		}
	}
	

#	my js [format { 

#	} $name ]

	#ex1Slider .slider-selection {
	#	background: #BABABA;
		#}
 #for 2 selectors.. do the value [25,50]
# set slider_options [list id $name name $name data-slider-id $sliderid \
#	 	data-slider-min $min data-slider-max $max data-slider-step $step data-slider-value $value ]
	set wizard [my tabs -pills 1 $tabs][my pager ] 
	return $wizard 

}

#TODO really, this is very important
##########################################
#TODO bootstro.js
#http://clu3.github.io/bootstro.js/#
# http://usablica.github.io/intro.js/   or use intro.js ? 
#Making presentations of your application or showing users how to do some things!
##########################################



##########################################
# TODO Eldarion AJAX sending ajax etc
#https://github.com/eldarion/eldarion-ajax/
##########################################


##########################################
# Syntax Highlight
#http://alexgorbatchev.com/SyntaxHighlighter/download/
##########################################
bhtml public method syntaxHighlighter {args} {

	#ns_parseargs {   } $args
	if {![my existsPlugin syntaxhighlighter]} {
		my addPlugin syntaxhighlighter { 
			js { /js/sh/shCore.js /js/sh/shAutoloader.js }
			js-min { /js/sh/shCore.js /js/sh/shAutoloader.js }
			css { /css/sh/shCore.css /css/sh/shCoreMidnight.css }
			css-min { /css/sh/shCore.css /css/sh/shCoreMidnight.css }
		}

	}
	

	my js [format { 
	/*	SyntaxHighlighter.autoloader(
			'js jscript javascript /js/sh/shBrushJScript.js',
			'bash /js/sh/shBrushBash.js'
		);*/
		   function brushpath()
      {
        var args = arguments,
            result = []
            ;
             
        for(var i = 0; i < args.length; i++)
            result.push(args[i].replace('@', '/js/sh/'));
             
        return result
      };
       
      SyntaxHighlighter.autoloader.apply(null, brushpath(
        'applescript            @shBrushAppleScript.js',
        'actionscript3 as3      @shBrushAS3.js',
        'bash shell             @shBrushBash.js',
        'coldfusion cf          @shBrushColdFusion.js',
        'cpp c                  @shBrushCpp.js',
        'c# c-sharp csharp      @shBrushCSharp.js',
        'css                    @shBrushCss.js',
        'delphi pascal          @shBrushDelphi.js',
        'diff patch pas         @shBrushDiff.js',
        'erl erlang             @shBrushErlang.js',
        'groovy                 @shBrushGroovy.js',
        'java                   @shBrushJava.js',
        'jfx javafx             @shBrushJavaFX.js',
        'js jscript javascript  @shBrushJScript.js',
        'perl pl                @shBrushPerl.js',
        'php                    @shBrushPhp.js',
        'text plain             @shBrushPlain.js',
        'py python              @shBrushPython.js',
        'ruby rails ror rb      @shBrushRuby.js',
        'sass scss              @shBrushSass.js',
        'scala                  @shBrushScala.js',
        'sql                    @shBrushSql.js',
        'vb vbnet               @shBrushVb.js',
        'xml xhtml xslt html    @shBrushXml.js'
      ));
		SyntaxHighlighter.all();
	} "" ]

}




##########################################
#TODO Bootstrap acknowledge inputs
# http://averagemarcus.github.io/Bootstrap-AcknowledgeInputs/
# Give user visual feedback on the page..
##########################################

##########################################
# Tag Cloud 
# 	Create a visual Tag Cloud
# 	Needs 1 variable tagCloud that is a dictionary containing
# 	columnNames (id tag count) and all the values
#
# 	Returns the HTML tag Cloud
##########################################
	#Generate HTML tag cloud..
	#TODO externalize in bhtml..?
bhtml public method genTagCloud {tagCloud {controller ""}} {
	set font_min 7
	set font_max 40
	set increment [expr {($font_max-$font_min)/10}]
	set result ""
	set values [dict get  $tagCloud values]
	set current_size $font_min
	#ns_parseargs {{-controller ""} {-url 1} -- text action {query ""}} $args
	foreach {id tag count} $values {
		set link [my link -controller $controller $tag tag [list tag $tag] ]
		set current_size [expr {$font_min+$increment*$count}]
		if {$current_size > $font_max} {
			if {$current_size > [expr {$font_max *3/2}]} {
				set current_size [expr {$font_max+log($count)*2}]	
			} else {
				set current_size [expr {int($font_max+($increment*$count)*0.1)}]
			}
		}  
		set textsize "font-size: ${current_size}px;"
		append result [my htmltag -htmlOptions [list style  "padding-right: 5px;$textsize display:inline-block;"] div $link  ]
	}
	#		set result [$bhtml htmltag -htmlOptions [list class col-xs-12] div $result]
	return $result
}
#A second more 'fine graiend" tag cloud generator.. for values higher and higher..
bhtml public method genTagCloud2 {tagCloud {controller ""}} {
	set font_min 6
	set font_max 40
	set increment [expr {($font_max-$font_min)/1000.}]
	set result ""
	set values [dict get  $tagCloud values]
	set current_size $font_min
	#ns_parseargs {{-controller ""} {-url 1} -- text action {query ""}} $args
	foreach {id tag count total} $values {
		set link [my link -controller $controller $tag tag [list tag $tag] ]
		set current_size [expr {$font_min+$increment*$total}]
		if {$current_size > $font_max} {
			if {$current_size > [expr {$font_max *3/2}]} {
				set current_size [expr {$font_max+log($total)*2}]	
			} else {
				set current_size [expr {int($font_max+($increment*$total)*0.1)}]
			}
		}  
		set textsize "font-size: ${current_size}px;"
		append result [my htmltag -htmlOptions [list style  "padding-right: 5px;$textsize display:inline-block;"] div $link  ]
	}
	#		set result [$bhtml htmltag -htmlOptions [list class col-xs-12] div $result]
	return $result
}

