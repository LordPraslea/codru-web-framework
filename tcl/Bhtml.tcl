# == Better HTML library  for LostMVC  
# More info at http://lostmvc.unitedbrainpower.com
#
#    Copyright (C) 2014-2015 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014-2015 United Brain Power <info@unitedbrainpower.com>
#
# This program is distributed according to GPL 3 license <http://www.gnu.org/licenses/>.
#
# This is the father of HTML/CSS/Javascript extensions.. 

# In this core  file we have:
# jQuery
# Bootstrap css/javascript items
# Font Awesome
#
# Other bootstrap/jquery plugins are included in Plugins.tcl


nx::Class create bhtml {

	:variable enableCdn true ;#true
	:variable fontAwesomeCss true ;#true
	:variable minifyCss true ;#true 


	#Global variable containing all scripts
	:variable scripts
	#Global variable containing all components..

	:variable components 

 	:variable plugins  

	:property -accessor public {Controller:optional ""}
	:property -accessor public {cdn true}

# == Init method
	:method	init {} {

		set :scripts {
			$('[data-toggle="tooltip"]').tooltip();
			$('[data-toggle="popover"]').popover({trigger: "hover"});
		}
		set :components ""
		set :plugins {
			jquery { 	
				js {/js/jquery.js}
				js-min {/js/jquery.min.js} 
			}
			bootstrap {
				css {"/css/bootstrap.css" }
				css-min {"/css/bootstrap.min.css" }
				js "/js/bootstrap.js"
				js-min "/js/bootstrap.min.js"
				version "3.2.0"
				authors "Bootstrap Twitter Team"
			}
			lostmvc { css "/css/lostmvc.css" css-min "/css/lostmvc.css" }
		}

		#If the previous context was an object
		#It certainly must have been the Controller, so take the controller from there!

	}

# == Include Plugins
#	This generates the JavaScript Script and CSS link HTML tags.
	
	:public method includePlugins {} {
		set :cssinclude ""
		set :jsinclude ""
		set :includeMinified 1

		#TODO play with cdn
		set location [split [ns_conn location] /]
		set host [lindex $location 2]
		set jshost [join  [lreplace $location 2 2 js.$host] /]
		set csshost [join  [lreplace $location 2 2 css.$host] /]

		foreach plugin [dict keys ${:plugins}] {
			foreach {type file} [dict get ${:plugins} $plugin] {
			#	puts "PLUGIN $plugin of $type and $file"
				#If cdn = true.. we get javascript/css from 2 cnd's
				:switchPluginType $type $file
			}
		}
	#puts "All all keys are [dict keys $plugins]  javascript included is $jsinclude"	
		return "${:cssinclude} ${:jsinclude}"
	}
	
	:method switchPluginType {{-includeMinified 1} -- type file} {
		if {$includeMinified} {
			foreach {js css} {js-min css-min} { }
		} else { 
			foreach {js css} {js-min css-min} { }
		}
		#			if {${:cdn}} {  set file $cssfile/$file				}
		if {$type == $css} {
			foreach f $file {
				append :cssinclude "\n" [format {<link href="%s" rel="stylesheet">} $f]
			}
		} elseif {$type == $js} {
			foreach f $file {
				append :jsinclude "\n" [format {<script src="%s"></script>} $f]
			}
		}

	}


	:public method existsPlugin {name} {
		return [dict exists ${:plugins} $name]
	}
	:public method addPlugin {name data} {
			dict set :plugins $name $data  
	}

# === Misc things
# Misc scripts, components and javascript  functions
# 	
	:public method components {} {
		return ${:components}
	}
	:public method js {data} {
		append :scripts \n $data
	}

	:public method putScripts {} {
		set script "<script> \n   \$(document).ready(function()\{"

		append script \n ${:scripts}
		append script  \n "\}); \n    </script>"
		return $script
	}


# == tag , html or htmltag 
# Creating html tags.. good for now
	:public method htmltag {{-htmlOptions ""} {-closingTag 1} {-singlequote 0} -- tag {data ""}} {
		set attributes ""
		set quote { %s="%s"} 
		if {$singlequote} {
			set quote { %s='%s'} 
		} 
		foreach {name value} $htmlOptions {
		#	append attributes  " ${name}=\"${value}\""
			append attributes [format $quote ${name} ${value}]
		}
		set html [format {<%s%s%s>} $tag $attributes [expr {$closingTag?"":" /"}]]
		append html $data
		if {$closingTag}  {
			append html "</$tag>"
		}
		return $html
	}
	#Aliases
 	:public	method html {args} {
		my htmltag {*}$args			
	}
	
	:public method tag {args} {
		my htmltag {*}$args
	}

	##########################################
	# TODO Grid System...
	##########################################



# === Alert 
# alert-link class for links inside alerts
	:public method alert {{-type info} {-class ""}  -- data} {
		#Enable settings like
		#What type of an alert it shoud be
		# id, visible
		#Do a button or not? 
		#Fade in, fade out by javascript
		#
		#TODO add other selectors specific!
		#	set script {<script> $('.alert').alert(); </script>}

		foreach cls $class { dict lappend listOptions class $cls }
		set button [my htmltag -htmlOptions [list type button class close data-dismiss alert aria-hidden true] button "&times;"] 
		set tag [my htmltag  -htmlOptions [list class "alert alert-${type}"] div "$button	$data" ]

		#	append tag $script
		return $tag
	}

	#"
	##########################################
	# Badge and label 
	##########################################
	:public method spanlabel {{-type info} -- data} {
		#type success	warning	important	info 	inverse
		set tag [my htmltag -htmlOptions [list class "label label-${type}"] span $data] ;#"
		return $tag
	}
	:public method badge {{-type info} -- data} {
		set tag [my htmltag -htmlOptions [list class "badge label-${type}"] span $data] ;#"
		return $tag
	}

	##########################################
	# Jumbotron / Hero unit 
	########################################
	:public	method jumbotron {{-htmlOptions ""} -- heading data} {
		#TODO further implement..
		set heading [my htmltag h1  $heading]
		set html [my htmltag  -htmlOptions [list class jumbotron] div "$heading $data"]
		return $html

	}

	##########################################
	# Breadcrumbs 
	##########################################
	:public method breadcrumb {{-type info} {-container 0} -- data} {		
		set breadcrumb [my makeList -htmlOptions [list class breadcrumb ] -type ol $data  ]

		if {$container} {
			set breadcrumb [my tag -htmlOptions [list class container] div $breadcrumb ]
		}
		return $breadcrumb
	}

	##########################################
	# Blockquote 
	##########################################
	:public	method blockquote {{-source ""} {-reverse 0} -- data} {
		set htmlOptions ""
		if {[string length $source]>0} {
			append data [my htmltag footer $source]		
		}
		if {$reverse} {
			set htmlOptions [list class blockquote-reverse]
		}
		set html [my htmltag -htmlOptions $htmlOptions blockquote $data ]	
		return $html ;#you can comment this and it will still return a value in naviserver:)
	}

	##########################################
	# Lists 
	##########################################
	#These can be recursive..
	##htmlOptions
	#class can be list-inline, list-unstyled
	#Handling url in list... so we don't have to do subst..blabla
	# Can use grouping..
	# you can set class -class list-group-item-danger etc
	#
	:public method makeList {{-type "ul"} {-htmlOptions ""}  {-group 0}  {-activeli ""}  -- data} {
		if {$group} { dict lappend  htmlOptions class list-group  }
		foreach list  $data {
			append html_list [:makeListItem -activeli $activeli -group $group  {*}$list ]	
		}

		set html [my htmltag -htmlOptions $htmlOptions $type  $html_list]
		return $html
	}
	
	:method makeListItem { {-activeli ""} {-group 0} {-show 1} {-dropdown 0} {-dropup 0} {-class ""} 
							 {-active 0} {-disabled 0} {-url 0} {-newlist 0} 
							  {-p ""} {-listOptions ""}  -- args} {
		set list $args
		#Show only if show is positive
		if {!$show} { continue }

		if {$dropdown} {
			dict lappend listOptions class dropdown
			set list [my dropdown {*}$list]
		}
		if {$dropup} {
			dict lappend listOptions class dropup
			set list [my dropdown {*}$list]
		}

		#Hack to make this active
		if {$activeli != ""} {
			if {[string match *$activeli* [lindex $list end]]} { dict lappend listOptions class active   } 
		}

		if {$newlist} { set list [my makeList {*}$list]  }

		if {$url} { set list [my a {*}$list]  }

		if {$active} { dict lappend  listOptions class active ; set list [join $list]  } 
		if {$disabled} { dict  lappend listOptions disabled ; set list [join $list]  }

		foreach cls $class { dict lappend listOptions class $cls }

		if {$p != ""} { set list "$p $list" }  
		if {$group} { dict lappend listOptions class list-group-item  }

		return [my htmltag -htmlOptions $listOptions li $list]

	}


	#what this does is make a list-group with a div and a instead of ul/li
	#It's very simple, not as complex as makeList..
	:public method makeGroup {{-htmlOptions ""}     -- data} {
		dict lappend  htmlOptions class list-group  

		foreach list  $data {
			set listOptions "class list-group-item"
			ns_parseargs {{-active 0} {-class ""} {-h ""} {-p 0} {-url "#"} {-newlist 0} {-type ""}   -- text } $list
		#you can set the parseargs text to args..
		#set text $args
			foreach cls $class { dict lappend listOptions class $cls }
			if {$p} { set text [my htmltag -htmlOptions [list class "list-group-item-text"] p $text]}
			#Add the header as first item
			if {$h != ""} {set text [format "%s %s"  [my htmltag -htmlOptions [list class "list-group-item-heading"] h4 $h] $text] }
			if {$active} { dict lappend  listOptions class active   } 

			if {$type != ""} { dict lappend listOptions class [my returnType "list-group-item" $type]}	

			dict set 	listOptions href $url
			append html_list [my htmltag -htmlOptions $listOptions a $text]
		}

		set html [my htmltag -htmlOptions $htmlOptions div  $html_list]
		return $html
	}
	##########################################
	# Description 
	##########################################
	 :public method desc {{-horizontal 0} -- data} {
		set htmlOptions ""
		foreach {term description} $data {
			append html_list [my htmltag dt $term]
			if {$description == ""} { set description "&nbsp;" }
			append html_list [my htmltag dd $description]
		}
		if {$horizontal} { dict lappend htmlOptions class dl-horizontal}
		return [my htmltag -htmlOptions $htmlOptions dl $html_list ]
	}

	##########################################
# Table
# 	Create beautiful tables without having to code everything..
	# ##########################################
	#At the moment no rowspan, no colspan..sorry:)
	#TODO.. for each TD/TR add a contextual class
	# .active .success .info .warning .danger
	# Maybe do this by splitting up td/tr function creation:) 
	# RPR or row per row settings 
	#
	# 0. Either get a whole list and calculate each row based on the total columns
	# 	It's nearly impossible to impose per row settings from the list
	# 	No problem with cell specific settings
	#
	# 1. Get a list of sublists where each sublist is a row
	# 	Very easy to impose row and cell specific settings
	###
	#
	:public method tableHorizontal {{-rpr 0} {-striped 0} {-bordered 0} {-hover 0} {-condensed 0} {-responsive 0} {-class ""} {-hwidth 30} -- header data} {
		set tdOptions ""
		set htmlOptions [dict create class table]

		#Different options
		if {$striped} { dict lappend htmlOptions class "table-striped"}
		if {$bordered} { dict lappend htmlOptions class "table-bordered"}
		if {$hover} { dict lappend htmlOptions class "table-hover"}
		if {$condensed} { dict lappend htmlOptions class "table-condensed"}
		if {$responsive} { dict lappend htmlOptions class "table-responsive"}

		foreach cls $class { dict lappend tdOptions class $cls }

		set length [llength $header]
		set datalength [llength $data]
		set perdata [expr {$datalength/$length}]
		
		#Horizontal table implementation
	#thead to contain 2 columns "Column Name" " Data"
	
		for {set i 1} {$i<=$datalength} {incr i} {
		
				append row [my htmltag -htmlOptions $tdOptions td [lindex $data $i-1]]
				if {![expr {$i%$perdata}]} { 
					set headdata  [lindex $header [expr $i/$perdata-1]]
					set head [my htmltag -htmlOptions [list width ${hwidth}%] th $headdata ]
					set row "$head $row"
					append tbody [my htmltag tr $row ]	
					set row ""
				}
		}
	
		append html [my htmltag tbody $tbody]
		return [my htmltag -htmlOptions $htmlOptions table $html]
	}
	
	:public	method table {{-rpr 0} {-striped 0} {-bordered 0} {-hover 0} {-condensed 0} {-responsive 0} {-class ""} {-id ""} -- header data} {
		set htmlOptions [dict create class table]
		set html ""

		#Different options
		if {$striped} { dict lappend htmlOptions class "table-striped"}
		if {$bordered} { dict lappend htmlOptions class "table-bordered"}
		if {$hover} { dict lappend htmlOptions class "table-hover"}
		if {$condensed} { dict lappend htmlOptions class "table-condensed"}
		if {$responsive} { dict lappend htmlOptions class "table-responsive"}

		if {$id != ""} { dict set htmlOptions id $id }

		foreach cls $class { dict lappend tdOptions class $cls }

		#Length of header defines how many columns there are
		#Append a th to each column
		set length [llength $header]

		append html [:generateTableHeader $header]

		#Body Handling
		if {$rpr} {
			set tbody [:rowPerRowTableData]
		} else {
			set tbody [:perItemTableData]
		}

		append html [my htmltag tbody $tbody]
		return [my htmltag -htmlOptions $htmlOptions table $html]
	}

	:method generateTableHeader {header} {
		foreach head $header {
			ns_parseargs {{-class ""} {-url 0} {-tdOptions ""}  -- args} $head
			set head $args
			#	ns_puts "<br>whazzup $head"
			if {$url} { set head [my a {*}$head]  }
			foreach cls $class { dict lappend tdOptions class $cls }
			append th [my htmltag -htmlOptions $tdOptions th $head]

		}
		
		return   [my htmltag thead [my htmltag tr $th ]]
	}

	:method rowPerRowTableData {} {
		upvar data data
		set rowOptions [set type ""]
		foreach row $data {
		#Parse the args to view if they contain any hidden settings..
			ns_parseargs {{-type ""} {-id ""} -- args} $row
			set row $args
			if {$type != ""} { set rowOptions [list class $type]   } else {set rowOptions ""}
			if {$id != ""} { dict set rowOptions  id $id   } 

			#args = row
			foreach cell $row {

				ns_parseargs {{-type ""} -- args} $cell
				set cell $args

				if {$type != ""} { set cellOptions [list class $type]   } else {set cellOptions ""}
				#parse the args of each cell to view if they contain any hidden settings
				append cells [my htmltag  -htmlOptions $cellOptions td $cell]	
			}
			append tbody [my htmltag  -htmlOptions $rowOptions tr $cells]
			set cells ""
		}
		return $tbody
	}

	:method perItemTableData {} {
		upvar data data length length
	#Just a big list of data, manualy split rows
		set count 1; set row ""
		foreach item $data {

			append row [my htmltag -htmlOptions $tdOptions td $item]

			#Each new row is added
			if {![expr {$count%$length}]} { 
				append tbody [my htmltag tr $row ]	
				set row ""
			}
			incr count	
		}
		return $tbody
	}


	##########################################
	# Form 
	##########################################
	#TODO class like options.. create form then add thigns to it
	#TODO when making horizontal form..make all other things horizontal!
	# this means modifying each item to incluse a column..
	:public	method form {{-horizontal 0}  {-inline 0} {-method "GET"} {-action ""} {-class ""} {-id ""} -- data} {
		set htmlOptions [dict create role form]
		set html ""
		dict lappend htmlOptions method $method
		#Different options
		#TODO add .sr-only for all lables when using inline tables..
		if {$class != ""} { foreach cls $class { dict lappend htmlOptions class $cls} }
		if {$inline} { dict lappend htmlOptions class "form-inline"}
		if {$horizontal} { dict lappend htmlOptions class "form-horizontal"}
		if {$action != ""} { dict lappend htmlOptions action $action}
		if {$id != ""} { dict set htmlOptions id $id}

		return [my htmltag -htmlOptions $htmlOptions form $data ]
	}

	#FormGroup to bind together input and lable fields..
	#Group lable and input with form-group
	#each input is a form-control!
	#has-feedback
	:public method formGroup {{-class ""} {-type ""} --  data } {

		set htmlOptions [dict create class "form-group "]

		if {$class != ""} { foreach cls $class { dict lappend htmlOptions class $cls} }
		if {$type != ""} { dict lappend htmlOptions class [my returnType "has" $type]}	

		foreach item $data {
			ns_parseargs {{-input 0} {-label 0} {-listOptions ""}  -- args} $item
			set item $args

			if {$input} { set item [input {*}$item]  }
			if {$label} { set item [label {*}$item]  }

			append html_items $item
		}

		return [my htmltag -htmlOptions $htmlOptions div $data]
	}



	##########################################
	# Label 
	##########################################
	:public method label {{-for ""} {-class ""}   -- data} {
		set htmlOptions [dict create class "control-label"]

		if {$for>0} { dict set htmlOptions for $for }
		if {$class !=""} { foreach cls $class { dict lappend htmlOptions class $cls } } 	
		return [my htmltag -htmlOptions $htmlOptions label $data ]

	}

	##########################################
	# input 
	##########################################
		#Most common form control, text-based input fields. 
		#Includes support for all HTML5 types: 
		#text, password, datetime, datetime-local, date, month, time, week, number, email, url, search, tel, and color.
		#TODO all inputs to have DISABLED option!
		#<fieldset disabled="disabled"> to disable the whole fieldset!
		#		set htmlOptions [dict create class ""]
	:public	method input {{-htmlOptions ""} {-type "text"} {-class "form-control"} {-id ""} {-placeholder ""} 
					   {-popover ""} {-tooltip ""}  {-left ""} {-right ""}
					   -- name {value ""}} {
		set :leftSpan [set :rightSpan ""]

		if {$type !=""} { dict set htmlOptions type  $type}	
		if {$value != ""} { dict set htmlOptions value $value }
		if {$placeholder != ""} { dict set htmlOptions placeholder $placeholder }
		if {$class != ""} { foreach cls $class  { dict lappend htmlOptions class $cls } }
		if {$id != ""} { dict set htmlOptions id $id }
		dict lappend htmlOptions name $name

		:inputGroupAddon 

		#this was done with lappend.. now with set.. 
		if {$tooltip != ""} { foreach {opt val} [my tooltip {*}$tooltip] { dict set htmlOptions $opt $val } }
		if {$popover != ""} { foreach {opt val} [my popover {*}$popover] { dict set htmlOptions $opt $val } }

		set inputHtml [my htmltag -closingTag 0 -htmlOptions $htmlOptions input ]
		 if {$left != "" || $right != ""} {
		 	return [:tag -htmlOptions [list class input-group] div "$leftSpan $inputHtml $rightSpan"]
		 } else {
			 return $inputHtml
		 }
	}

	:method inputGroupAddon {} {
		upvar right right left left

		if {$left !=""} {
			set :leftSpan [:tag -htmlOptions [list class input-group-addon] span $left]
		}
		if {$right !=""} {
			set :rightSpan [:tag -htmlOptions [list class input-group-addon] span $right]
		}
	}

##########################################
# TODO input group addon 
##########################################
# Warnings & limitations from bootstrap
#only <input> 
#tooltips &popovers require .input-group  and container:'body' 
#always add labels
#no support for multiple addons on a single side
#no support for multiple form-controls in a single input group

	
	if {0} {
		Adding a span to create a beautiful input groups
		<div class="input-group">
		<span class="input-group-addon">$</span>
		<input type="text" class="form-control">
		<span class="input-group-addon">.00</span>
		</div>
		INPUT group addon with checkbox    
		<div class="input-group">
		<span class="input-group-addon">
		<input type="checkbox">
		</span>
		<input type="text" class="form-control">
		</div><!-- /input-group -->
		Button Addon!
		<div class="input-group">
		<input type="text" class="form-control">
		<span class="input-group-btn">
		<button class="btn btn-default" type="button">Go!</button>
		</span>
		</div><!-- /input-group -->
		You can also do dropdowns..
		div class=input-group-btn

	}

	##########################################
	# checkbox and radiobutton bootstrapping to type less code..
	##########################################
	:public	method checkbox {{-id ""} {-inline 0} {-class ""} -- name text} {
		set htmlOptions [dict create class checkbox]
		if {$inline} { dict set htmlOptions class checkbox-inline }

		set input [my input -class $class -type checkbox $name]
		set label [my label [concat $input $text]]
		return [my htmltag  -htmlOptions $htmlOptions div $label]
	}

	:public method radio {{-id ""} {-inline 0} {-class ""} -- name  args} {

		set htmlOptions [dict create class radio]

		foreach {value text} $args {
			if {$inline} { dict set htmlOptions class radio-inline }

			set input [my input -class $class -type radio $name $value]
			set label [my label [concat $input $text]]
			append html [my htmltag  -htmlOptions $htmlOptions  div $label]
		}
		return $html
	}



	##########################################
	# Textarea 
	##########################################
	:public method textarea {{-rows 3} {-placeholder ""} {-id ""} {-options ""}  -- name {text ""}} {
		set htmlOptions [list class "form-control" id $id name $name placeholder $placeholder rows $rows {*}$options]

		return [my htmltag -htmlOptions $htmlOptions  textarea $text]
	}

##########################################
# Select 
# 	Also handles optgroup html 
##########################################
	:public method select {{-multiple 0} {-class ""} {-selected ""}  {-id ""} {-optgroup 0} -- data {name ""}} {
		set htmlOptions [dict create class "form-control"]
		set html ""

		if {$class !=""} { foreach cls $class { dict lappend htmlOptions class $cls } } 	
		if {$multiple} {dict set htmlOptions multiple multiple}
		if {$name != ""} { dict set htmlOptions name $name }
		if {$id != ""} { dict set htmlOptions id $id }

		if {$optgroup} {
			set html [:selectOptGroup $name $data]	
		} else {
			foreach {name val} $data {
				dict set optOptions value $val
				if {$selected == $val} { dict set optOptions selected selected  }
				append html [my htmltag  -htmlOptions $optOptions option  $name]
				unset optOptions
			}
		}

		return [my htmltag -htmlOptions $htmlOptions select $html ]
	}

	:method selectOptGroup {} {
		upvar name name data data
		foreach {group options} $data {
			foreach {name val} $options {
				dict set optOptions value $val
				if {$selected == $val} { dict set optOptions selected selected  }
				append interhtml [my htmltag  -htmlOptions $optOptions option  $name]
				unset optOptions
			}
			append html [my htmltag -htmlOptions [list label $group]  optgroup $interhtml ]
			unset interhtml
		}

		return $html
	}

	##########################################
	# Fontawesome integration is very simple 
	##########################################
	:public method fa {args} {
		if {![dict exists ${:plugins} fontawesome]} {
			dict set :plugins fontawesome { 
				css  "/css/font-awesome.css"
				css-min  "/css/font-awesome.min.css"
			}
		}
		set htmlOptions [dict create class fa]
		foreach arg $args {
			dict lappend htmlOptions class $arg
		}
		return [my htmltag -htmlOptions $htmlOptions span]
	}

	#glyphicons functionality for carousel..
	:public method glyphicon {args} {
		set htmlOptions [dict create class glyphicon]
		foreach arg $args {
			dict lappend htmlOptions class $arg
		}
		return [my htmltag -htmlOptions $htmlOptions span]
	}


##########################################
# Button.. 
##########################################
		# btn-default btn-primary btn-success btn-info btn-warning btn-danger btn-link
						# btn-lg btn-sm btn-xs
						# btn-block block level..
						# Only BUTTONS are supported with navbar
	:public method button {{-options ""}  {-class ""}  {-type "button"} {-fa "" }  {-id ""} {-placeholder ""} {-value ""} {-name ""} 
						-- data} {
		set htmlOptions { class btn}

		if {$type>0} { dict lappend htmlOptions class [my returnType "btn" $type]}	
		foreach {opt val} $options {
			dict set htmlOptions $opt $val 
		}
		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$name != ""} { dict set htmlOptions value $name }
		if {$value != ""} { dict set htmlOptions value $value }
		if {$placeholder != ""} { dict set htmlOptions placeholder $placeholder }
		if {$id != ""} { dict set htmlOptions id $id }

		if {$fa !=""} {
			set fa [my fa {*}$fa]
		}
		return [my htmltag -htmlOptions $htmlOptions button "$fa $data" ]
	}

# Button Group 
# btnType can be either a or button
	:public method buttonGroup { {-vertical ""} {-size ""} {-btnType a} buttonToolbar } {
		set htmlOptions [list class btn-group role group]
		if {$vertical != ""} { dict lappend htmlOptions class btn-group-vertical }	
		if {$justified != ""} { dict lappend htmlOptions class btn-group-justified }	
		if {$size != ""} { dict lappend htmlOptions class "btn-group-$size" }
		
		foreach buttonGroup $buttonToolbar {
			foreach btn $buttonGroup {
				append htmlButtons " " [:$a {*}$btn]
			}
			append htmlButtonGroup [:htmltag -htmlOptions $htmlOptions div $htmlButtons ] 
			unset htmlButtons
		}
		return [:htmlTag -htmlOptions [list class btn-toolbar role toolbar] div $htmlButtonGroup] 
	}


	##########################################
	# Anchors 
	##########################################
	:public method a { {-class ""} {-title ""} {-new 0} {-htmlOptions ""} {-id ""} {-tooltip ""}  {-fa ""} {-type ""}
					{-tooltip ""} {-popover ""} -- text {link "#"}} {
					#set htmlOptions { class btn role button}

		dict set htmlOptions href $link
		if {$new} { dict set htmlOptions target "_blank"}
		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$tooltip != ""} { foreach {opt val} [my tooltip $tooltip] { dict lappend htmlOptions $opt $val } }
		if {$id != ""} { dict set htmlOptions id $id  }
		if {$title != ""} { dict set htmlOptions title $title  }
		if {$fa != ""} { set text "[my fa {*}$fa] $text" }

		if {$type != ""} { dict lappend htmlOptions class [my returnType "btn" $type]  };

		if {$tooltip != ""} { foreach {opt val} [my tooltip {*}$tooltip] { dict set htmlOptions $opt $val } }
		if {$popover != ""} { foreach {opt val} [my popover {*}$popover] { dict set htmlOptions $opt $val } }
		return [my htmltag -htmlOptions $htmlOptions a $text ]
	}

	:public method getUrl {{-controller ""}   {-url 1} {-lang ""} -- action {query ""}} {

		if {$controller == ""} {
			set controller ${:Controller} 
		}

		set link /$controller/$action[ns_queryencode {*}$query]
		if {$controller == false} {
			set link /$action[ns_queryencode {*}$query]
		} 
		set urlLang [ns_session get urlLang]

		if {${urlLang} ne "na"} { 
			if {$lang eq ""} {
				set lang ${urlLang}
			}
			set link /${lang}$link
		}

		return $link	
	}

	#Link method working together with 
	:public method link { {-controller ""}  {-new 0} {-htmlOptions ""} {-simple 0}  {-lang ""} -- text url {query ""}} {
		if {$controller == ""} {
			set controller ${:Controller} 
		}

		if {!$simple} {
			set newUrl [:getUrl -controller $controller -lang $lang  $url $query  ]
		} else {
			set newUrl $url
		}
		set link [my a -htmlOptions $htmlOptions -new $new $text $newUrl]
		return $link	
	}


	##########################################
	# errorMsg 
	##########################################
	#This is to be placed next to the input with errors..
	# Don;t forget to create a list with all that went wrong fot the top of the page
	:public method errorMsg { {-class ""} {-type ""}  -- data} {
		set htmlOptions [list class help-block]

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		return [my htmltag -htmlOptions $htmlOptions span $data]
	}

	##########################################
	# Image 
	##########################################
	:public method img {{-class "img-responsive"}  {-htmlOptions "" } {-title ""} {-lazy 0} -- src {alt "" }} {
		set img ""
		#img-rounded img-circle img-thumbnail
		if {$alt != ""} { dict set htmlOptions alt $alt}
		if {$title != ""} { dict set htmlOptions title $title}
		if {$title == "" && $alt != ""} {
			dict set htmlOptions title $alt
		}

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}

		:imgGenerateHtml

		return  $img
	}

	:method imgGenerateHtml {} {
		foreach refVar {lazy src htmlOptions img} { upvar $refVar $refVar }

		#Lazy loader for images
		if {$lazy} {
			:imgIncludeLazyJs
			dict lappend htmlOptions class lazy
			dict set htmlOptions data-src $src

			set htmlOptionsLazy $htmlOptions
			dict lappend htmlOptionsLazy class jsonly
			dict set htmlOptionsLazy src $src
			#Provide noscript equivalent
			append img [:tag noscript [my htmltag -htmlOptions $htmlOptionsLazy -closingTag 0 img  ] ]
		} else {
			dict set htmlOptions src $src
		}

		append img [my htmltag -htmlOptions $htmlOptions -closingTag 0 img  ]
	}

	:method imgIncludeLazyJs {} {
		if {![my existsPlugin lazyload]} {
			my addPlugin lazyload { 
				js "/js/jquery.lazy.js"
				js-min "/js/jquery.lazy.min.js"
			}

			:js "jQuery('img.lazy').lazy();"
		}
	}

##########################################
# Dropdown 
##########################################
	#Implement dropdown buttons..
	#class="dropdown-menu dropdown-menu-right "
	# DROPUP bgn-group
	#TODO switch between button and a
	:public method dropdown {{-class ""} {-list 1} {-split 0} {-type "default"} {-datawidth 300} {-nav 0}  -- btnText data} {
		set htmlOptions { class btn-group};# class is either dropdown or btn-group
		set :buttonClass ""
		set :split $split 
		set :list $list

		if {!$nav} {
			set :buttonClass btn
		} else {
			set type ""
		}
		#	 set type [my returnType "btn" $type] 

		foreach cls $class { dict lappend htmlOptions class $cls }

		set btn [:dropdownSplitButtonHtml  $btnText  $type]
		set dropdown [:dropdownMenuHtml $data $datawidth]	

		if {$nav} {
			set return "$btn $dropdown" 	
		} else { 
			set return [my htmltag -htmlOptions $htmlOptions  div "$btn $dropdown" ]
		} 

		return $return 
	}

	:method dropdownSplitButtonHtml {btnText type} {
		set caret [my htmltag -htmlOptions [list class caret] span]
		set sr_only [my htmltag -htmlOptions [list class sr-only] span [mc "Toggle dropdown"]]
		
		if {!${:split}} {
			set btn [my a -class "dropdown-toggle ${:buttonClass}" -type $type -htmlOptions [list data-toggle dropdown] "$btnText $caret" #]
		} else {
			append btn [my a -type $type -class "${:buttonClass}" $btnText #] \n	
			append btn [my a -class "dropdown-toggle ${:buttonClass}" -type $type -htmlOptions [list data-toggle dropdown] "$caret \n $sr_only" #]
		}

		return $btn
	}

	:method dropdownMenuHtml {data datawidth} {
		#Dropdown menu
		if {${:list} == 1} {
			set dropdown [my makeList -htmlOptions [list class dropdown-menu role menu] $data ]
		} else {
			set dropdown [my htmltag -htmlOptions [list class dropdown-menu role menu style "width: ${datawidth}px; padding: 15px; padding-bottom: 0px;"] div $data ]
		}
		return $dropdown
	}

	##########################################
	# Navigation 
	##########################################

	##########################################
	# Tabs / Pills navigation 
	##########################################
	##basically ul/li structure 
	#nav-pills  nav-tabs
	#nav-stacked  for pills.. put them under eachother
	#nav-justified fill all place
	:public	method nav {{-class ""}  {-tabs 1} {-active ""}  {-style ""} -- data} {
		set htmlOptions { class nav}
		#if tabs = 1 using tabs if 0 using pills
		dict lappend htmlOptions class [expr {$tabs ? "nav-tabs" : "nav-pills"}  ]

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$style != ""} {
			dict set htmlOptions style $style
		}

		return [my makeList -activeli $active -htmlOptions $htmlOptions $data]
	}


	##########################################
	# NavBar 
	##########################################
	#navbar-fixed-top
	#navbar-fixed-bottom
	#navbar-static-bottom / top
	#inverse
	#TODO which one is active?
	#	Either view LINK and 
	if {0} { 
			#tabs = 1 using tabs if 0 using pills
			dict lappend htmlOptions class [expr {$tabs ? "nav-tabs" : "nav-pills"}  ]
			makeList -htmlOptions $htmlOptions $data
		}
	:public method navbar {{-class ""} {-brand "Brand"} {-brandUrl #} {-active ""} {-navbarclass "" } {-navbarclass2 ""}
						{-data-target "lost-navbar-collapse-1"} {-tabs 0}
						-- data {extra ""}} {
						#TODO transfer options from outside..
		set htmlOptions [list class {navbar navbar-default} role navigation] 

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}

		:navbarHeaderHtml
		:navbarCollapseWithData

		set container [my htmltag -htmlOptions [list class container-fluid] div "${:navbar_header} ${:navbar_collapse}" ]
		set navbar [my htmltag -htmlOptions $htmlOptions nav $container ]

		return $navbar
	}

	:method navbarHeaderHtml {} {
		foreach refVar {brand brandUrl data-target} { upvar $refVar $refVar }

		set sr {
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		}

		#set brand [my htmltag -htmlOptions [list class "navbar-brand" href "#"] ]
		set brandHtml [my a -class "navbar-brand" $brand $brandUrl]

		#Button for when there's not enough space to show the items
		set head_button [my htmltag -htmlOptions \
			[list type button class "navbar-toggle collapsed" data-toggle "collapse" data-target "#${data-target}"] button $sr  ]
		set :navbar_header [my htmltag -htmlOptions [list class navbar-header] div "$head_button $brandHtml"]
	}

	:method navbarCollapseWithData {} {
		foreach refVar {data active extra navbarclass navbarclass2 data-target} { upvar $refVar $refVar }

		set links [my makeList -activeli $active -htmlOptions [list class "nav navbar-nav $navbarclass"] $data] ; #"
		if {$extra != ""} {
			append links " " [my makeList -activeli $active -htmlOptions [list class "nav navbar-nav $navbarclass2"] $extra] ;#"
		}
		set :navbar_collapse [my htmltag -htmlOptions [list class {collapse navbar-collapse} id ${data-target}] div $links]
	}


	##########################################
	# Pagination 
	# 	Building pagination effectively
	##########################################
	:public method pagination {{-class ""}  {-size 0} {-first {-url 1 "&laquo;" "#" } } {-last {-url 1 "&raquo;" "#" } }  -- data} {
		set htmlOptions { class pagination}
		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$size == -1} { dict lappend htmlOptions class "pagination-sm" }
		if {$size == 1} { dict lappend htmlOptions class "pagination-lg" }

		# more first and last
		#	set first {-url 1 "&laquo;" "#" }
		#	set last {-url 1 "&raquo;" "#" }

		set pagination [linsert $data 0 $first]
		lappend pagination $last
		return [my makeList -htmlOptions $htmlOptions $pagination]

	}

	##########################################
	# Pager 
	##########################################
	:public	method pager {{-class ""}  {-size 0}  -- {data ""}} {
		set htmlOptions { class pager}

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$size == -1} { dict lappend htmlOptions class "pagination-sm" }
		if {$size == 1} { dict lappend htmlOptions class "pagination-lg" }

		#TODO more options vor previous/next.. etc
		set previous [list -class previous -url 1 "&larr; [mc Previous]" "#" ]
		set next [list -class next -url 1  "[mc Next] &rarr;" "#" ]

		set pagination [linsert $data 0 $previous]
		lappend pagination $next

		return [my makeList -htmlOptions $htmlOptions $pagination]

	}


		##########################################
		# Progress bar 
		##########################################
		#use active in combination with striped
		#TODO stacked + multiple progressbars within one
	:public method progress {{-class ""} {-type ""}  {-min 0} {-max 100} {-striped 0} {-active 0}   -- now {data ""}} {
		set htmlOptions { class progress-bar role progressbar }
		set progressOptions {class progress}
		set barType 0

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		set sr [my htmltag -htmlOptions [list class sr-only] span "${now}% [mc Complete]"]

		foreach {name value} [list aria-valuenow $now aria-valuemin $min aria-valuemax $max ] {
			dict lappend htmlOptions $name $value
		}

		dict append htmlOptions style  "width: ${now}%;"
		if {$data == ""} { set data "${now}%" } 	

		if {$type != ""} { dict lappend htmlOptions class [my returnType "progress-bar" $type]  };
		if {$striped>0} {dict lappend progressOptions class progress-striped}
		if {$active} {dict lappend progressOptions class active}

		set progressbar [my htmltag -htmlOptions $htmlOptions div "$sr $data"]
		
		return [my htmltag -htmlOptions $progressOptions div $progressbar]
	}

	##########################################
	# TODO Media 
	##########################################
	#/!\TODO/!\ need to finish the implementation  and also tabbed input
	:public method media {{-class ""} {-type ""}   -- heading data } {
		set htmlOptions { class media  }

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		set img {
			data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI2NCIgaGVpZ2h0PSI2NCI+PHJlY3Qgd2lkdGg9IjY0IiBoZWlnaHQ9IjY0IiBmaWxsPSIjZWVlIi8+PHRleHQgdGV4dC1hbmNob3I9Im1pZGRsZSIgeD0iMzIiIHk9IjMyIiBzdHlsZT0iZmlsbDojYWFhO2ZvbnQtd2VpZ2h0OmJvbGQ7Zm9udC1zaXplOjEycHg7Zm9udC1mYW1pbHk6QXJpYWwsSGVsdmV0aWNhLHNhbnMtc2VyaWY7ZG9taW5hbnQtYmFzZWxpbmU6Y2VudHJhbCI+NjR4NjQ8L3RleHQ+PC9zdmc+
		}
		set i [my img $img]

		#TODO IMAGE SIZE ETC!
		set image [my a -class pull-left $i #]
		set heading [my tag -htmlOptions [list class media-heading] h4 $heading]
		set mediabody [my htmltag -htmlOptions [list ] div $heading$data]
		#if {$active} {dict lappend progressOptions class active}

		return [my htmltag -htmlOptions $htmlOptions div $image$mediabody]
	}


	##########################################
	#  Panels
	##########################################
	#Using panels to build beautiful stylish separate things..
	# Use the -component 1 value when the data is something of the following:
	# 	table , list, group list.. etc to style it
	# Use the -append when you have a component text, etc.. and want to add the following:
	# 	a table, list, group.. 
	:public method panel {{-class ""} {-h ""}  {-size ""}   {-type ""} {-f ""} {-component 0}  {-append ""} {-active 0}   -- data} {
		set htmlOptions { class {panel panel-default} }
		set :headingHtml ""
		set :footerHtml ""

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}

		if {$type != ""} { dict lappend htmlOptions class [my returnType "panel" $type]  };
		#	if {$active} {dict lappend progressOptions class active}
		if {$component == 1} {
			set body $data
		} else { 
			set body [my htmltag -htmlOptions [list class panel-body] div $data ]
		}

		if {$append != ""} { append body $append }

		set paneldiv [my htmltag -htmlOptions $htmlOptions div "${:headingHtml} $body ${:footerHtml}"]
		if {$size != ""} { set paneldiv [my tag -htmlOptions [list class $size] div $paneldiv] }
		return $paneldiv
	}

	:method panelHeaderAndFooter {} {
		#TODO any other heading h1-h6
		upvar h h f f paneltitle paneltitle
		if {$h != ""} {
			set paneltitle [my htmltag -htmlOptions [list class panel-title] h3 $h]
			set :headingHtml [my htmltag -htmlOptions [list class "panel-heading"] div $paneltitle] 
		}
		if {$f != ""} {
			set :footerHtml [my htmltag -htmlOptions [list class "panel-footer"] div $f] 
		}
	}

	##########################################
	# ReturnType is a fixall for all panels
	# it returns the correct "type" without headache
	##########################################
	:public method returnType {first type} {
		return "${first}-${type}"
	}



	##########################################
	# Well 
	##########################################
	:public method well {{-class ""}  -- data } {
		set htmlOptions { class well }

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}

		return [my htmltag -htmlOptions $htmlOptions div $data]

	}

	##########################################
	# JavaScript Bootstrap Components
	# 	These are all examples of JavaScript and bootstrap components
	##########################################



	##########################################
	# Modal
	# 	A Modal or PopUp that can contain anyother component:
	# 	form, table, page.. etc
	##########################################
	# Always place modal in toplevel position so other components doesn't afect it
	# This function generates a "modal" form
	# Maybe later it can also generate the button that activates it
	# IT returns the modal and/or button?
	# What I think at the moment:
	# Return button that activates it..
	#
	# And put all javascript in  global "scripts"
	# Put all html in global html variable.. that's outside of the page
	#
	#TODO modal-sm modal-lg  size
	#
	#TODO use events and load ajax page..
	#TODO beautify footer,header..etc:D
	:public method modal {{-class ""}  {-size ""} {-f ""} {-close ""} {-h ""} {-htype ""} {-ftype ""} {-id ""} {-zindex ""} {-button ""} -- title data } {
		set modalLabel modal-label-[generateCode 5 3]
		set htmlOptions [list  class "modal fade" aria-hidden true role dialog tabindex -1 aria-labelledby $modalLabel ] ; #"
		set modalFooter ""
	
		set modalHeader [:modalHeader]
		set modalFooter [:modalFooter]
	

		set body [my htmltag -htmlOptions [list class modal-body] div $data]
		set content [my htmltag -htmlOptions [list class modal-content] div "$modalHeader $body $modalFooter"]
		#INFO removing the next line makes the modal "Full screen width"
		set modalDialogHtml [my htmltag -htmlOptions [list class modal-dialog] div $content] 
		set modalHtml [my htmltag -htmlOptions $htmlOptions div $modalDialogHtml]

		#create the button to activate the modal without writing javascript
		#href "page" to load another page
		set modalbutton [my button -class "btn-primary btn-lg" -options [list data-toggle modal data-target "#${id}" ] $button]	
		append :components $modalHtml
		#ns_puts $html
		return $modalbutton

	}
	
	:method modalInitSettings {} {
		foreach refVar {close button class id zindex htype htmlOptions} { upvar $refVar $refVar }

		if {$close ==""} {
			set close [mc Close]
		}
		if {$button ==""} {
			set button [mc "Open Modal"]
		}
		foreach cls $class {
			dict lappend htmlOptions class $cls
		}

		if {$id == ""} { set id "modal-id-[generateCode 5 3]" }
		if {$zindex != ""} {  dict set  htmlOptions style "z-index: $zindex"  }
		if {$htype != ""} {    }

		dict set htmlOptions id $id 
	}

	:method modalHeader {} {
		upvar title title htype htype
		set closeBtn [my button -options [list data-dismiss modal aria-hidden true class close] "&times;"]
		set modalTitle [my htmltag -htmlOptions [list class "modal-title"] h4 $title]
		set modalHeader [my htmltag -htmlOptions [list class "modal-header $htype"] div "$closeBtn $modalTitle"] ; #"
		return $modalHeader
	}

	:method modalFooter {} {
		upvar close close ftype ftype f f
		set modalFooter ""
		if {$f != ""} {
			append f [my button -options [list data-dismiss modal] $close   ]	
			set modalFooter [my htmltag -htmlOptions [list class "modal-footer $ftype"] div $f] ;#"
		}
		return $modalFooter
	}



	##########################################
	#  Tabs 
	##########################################
	# TODO with and without javascript
	# TODO first navigation list, then tab content list?
	:public method tabs {{-class ""} {-pills 0} {-stacked 0} {-id ""} -- data} {
		set rand [generateCode 5 3 ]
		set htmlOptions { class tab-content }
		set navOptions [list  class [list nav nav-tabs] ]
		set navList ""
		set tabs ""

		foreach cls $class {
			dict lappend htmlOptions class $cls
		}
		if {$pills} { 
			dict lappend navOptions class nav-pills
			if {$stacked} { 
				dict lappend navOptions class nav-stacked
			}
		}

		:processTabsAndNavigationHtml

		#Navigation.. not using nav proc because we need to generate our own id"s
		set nav [my makeList -htmlOptions $navOptions $navList]
		set tabContent [my htmltag -htmlOptions $htmlOptions div $tabs]
		return "$nav $tabContent"
	}

	#Data contains settings and info for each tab
	:method processTabsAndNavigationHtml {} {
		upvar tabs tabs navList navList data data rand rand
		set first 1
		foreach tab $data {
			ns_parseargs {{-id ""} -- tabName tabData} $tab
			#-id tabId tabName {tabData} 
			if {$id == ""} {
				set id "[join [string tolower $tabName] _]-${rand}"
				#		set id "tab-${id}-${rand}" 
			} else { set id "tab-${id}" }
			#TODO make this more beautiful... as code
			if {$first} {
				set first 0; 
				lappend navList [list -active 1 -url 1 -htmlOptions {data-toggle tab}  $tabName #${id}]\n
				append tabs [my htmltag -htmlOptions [list class [list tab-pane fade active in] id $id] div $tabData]\n 
			} else {
				lappend navList [list -url 1 -htmlOptions {data-toggle tab}  $tabName #${id}]\n
				append tabs [my htmltag -htmlOptions [list class [list tab-pane fade] id $id] div $tabData]\n
			}
		}
	}

	##########################################
	# Accordion / Collapse 
	##########################################
	:public method accordion {{-class ""} {-id ""}  {-type default} -- data } {
		set rand [generateCode 5 3 ]
		set htmlOptions { class panel-group  }

		#Settings
		if {$id == ""} { set id "accordion-${rand}" }
		dict set htmlOptions id $id 
		set accordionID $id

		#Foreach data
		set first 1
		set in "in"

		set panels	[:processAccordionData]

		set panelgroup [my htmltag -htmlOptions $htmlOptions div $panels]
		return $panelgroup
	}

	:method processAccordionData {} {
		foreach refVar {data  accordionID rand in first type } { upvar $refVar $refVar }

		foreach panel $data {
			ns_parseargs {{-id ""} -- panelName panelData} $panel
			if {$id == ""} {
				set id "[join [string tolower $panelName] _]-${rand}"
			} else { set id "accordion-${id}" }

			# Heading 
			set a [my a -htmlOptions [list data-toggle "collapse" data-parent "#${accordionID}"] $panelName "#${id}"]
			set h [my htmltag -htmlOptions [list class panel-title] h4 $a]
			set heading [my htmltag -htmlOptions [list class panel-heading] div $h]

			#Body
			set panelbody [my htmltag -htmlOptions [list class "panel-body"] div $panelData]
			set collapse [my htmltag -htmlOptions [list class [list panel-collapse collapse $in] id $id] div $panelbody]

			if {$first} { set first 1; set in "" }
			#these panels to be added to panel-group

			if {$type != ""} { set panelType [my returnType "panel" $type]  };
			append panels [my htmltag -htmlOptions [list class [list panel $panelType]] div "$heading $collapse"  ] \n
		}
		return $panels
	}

	##########################################
	#  tooltip  "
	##########################################
	# This is a function that can be included in all others..
	# it returns tooltip settings
	# <button type="button" class="btn btn-default"
	# 		data-toggle="tooltip" data-placement="left"
	# 		title="Tooltip on left">Tooltip on left</button>
	#
	# 		TODO do this like the popover.. 
	#
	:public method tooltip {{-location "bottom"} -- title} {

		return [list data-toggle tooltip data-placement $location title $title]
	}


	##########################################
	#  popover 
	##########################################
	#TODO fix it further! 
	#TODO view example in method input
	#TODO extend with classes.. etc:D
	:public	method popover {{-location "bottom"} {-title ""} {-id ""} -- content} {
		if {$id != ""} {
			set content [my tag -singlequote 1 -htmlOptions [list id $id] div $content]
		}
		return [list data-toggle popover data-placement $location data-content $content title $title]
	}



	##########################################
	# Carousel 
	##########################################
	:public	method carousel {{-class ""} {-id ""} -- data } {
		set rand [generateCode 5 3 ]
		set htmlOptions [list  class [list carousel slide] data-ride carousel]
		set carouselItems ""
		set indicators ""

		#Settings "
		if {$id == ""} { set id "carousel-${rand}" }
		dict set htmlOptions id $id 
		set i 0
		set active "active"

		:processCarouselItems 

		return [my htmltag -htmlOptions $htmlOptions div [:processCarouselHtml] ]
	}

	:method processCarouselItems {} {
		foreach refVar {data id active carouselItems indicators i } { upvar $refVar $refVar }

		foreach panel $data {
			ns_parseargs { slideImg slideName } $panel
			#Carousel Indicators
			if 	{$i > 0} { set active "" }
			lappend indicators [list -listOptions [list data-target #${id} data-slide-to $i class $active]  ]

			#Slides
			set caption [my htmltag -htmlOptions [list class "carousel-caption"] div $slideName]
			set img [my img  $slideImg $slideName ]
			append carouselItems [my htmltag -htmlOptions [list class  [concat item $active]] div [concat $img $caption]] \n ; #"
			incr i	
		}
	}
	
	:method processCarouselHtml {} {
		foreach refVar {carouselItems indicators id} { upvar $refVar $refVar }
		#Contains all Carousel items "
		set inner [my htmltag -htmlOptions [list class "carousel-inner"] div $carouselItems ]

		set carousel_indicators [my makeList -type ol -htmlOptions  [list class "carousel-indicators"] $indicators] 
		#Controls
		#this was originally [fa fa-chevron-*] but was converted to glyphicon because of bootstrap "functionality"
		set prev [my a -class "left carousel-control" -htmlOptions [list data-slide prev] [my fa fa-chevron-left fa-3x] "#${id}" ]
		set next [my a -class "right carousel-control" -htmlOptions [list data-slide next] [my fa fa-chevron-right fa-3x] "#${id}" ]
		#Some style modifications..

		set	carousel "[:carouselStyleCss] $carousel_indicators $inner  $prev $next"
		return $carousel
	}

	:method carouselStyleCss {} {
		set fastuff {
			<style type="text/css">
			.carousel-control .fa-chevron-left {
				left: 50%;
			}
			.carousel-control .fa-chevron-right {
				right: 50%;
			}
			.carousel-control .fa-chevron-left,
			.carousel-control .fa-chevron-right {
				position: absolute;
				top: 50%;
				z-index: 5;
				display: inline-block;
			}

			</style>
		}
		return $fastuff
	}


	##########################################
	# TODO scrollspy implement this 
	##########################################

	##########################################
	# TODO affix (spy etc) implement this
	##########################################



	##########################################
	#  TODO Exporting functions that can be used without creating an object
	#  These functions don't modify anything in the
	#  scripts, plugins or components variables and don't influence the
	#  whole page markup
	##########################################
	#export alert htmltag a fa label input alert form formGroup errorMsg 
}



