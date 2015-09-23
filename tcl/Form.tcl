#################################
# Generator class
# 	Helping in generating some automatic things 
#################################
#	 LostMVC version 1.0	 -	 http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014 United Brain Power <info@unitedbrainpower.com>
#	Licensing according to GPL 3.0


#Form handling.. with bootstrap
# this generates a form where you can append things to
# Making it easier to generate bootstrap forms that follow some type of database model
# verifying if model data is.. all right
# Give possibility to create the fields manually but also to generate it automatically
#
nx::Class create Form {
#	variable group 
	:variable beforeForm ""
	:variable form  formdata
	:variable group ""
	:variable formdata  ""


	:property {inputSize 9}
	:property {labelSize 3}
	:property bhtml:required,object,type=bhtml
	:property model:required,object,type=Model 
	:property {formType normal}


	:method init {} {
		set attributes [${:model} getAttributes]
	}	


	#This encapsulates the bootstrap functions..
	#figure out a better way to do this in the future
	:public method add {data} {
		append :${:form} $data
	}

	:public method alert {args} {
		append :${:form} [${:bhtml} alert {*}$args]
	}

	:public method select {{-selected ""} -- name selectdata} {
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]

		if {[ns_queryget $id] != ""} {
			set data [ns_escapehtml [ns_queryget $id]]
		#	set data [ns_queryget $id]
		} else { 
			#ns_escapehtml here too!
			set data [ns_escapehtml [${:model} get $name]]
		}
		set select [${:bhtml} select -id $id -selected $data  $selectdata $id]
		append :${:form} $select
	}

	
	#	validate type between input textarea ckedior
	#regexp {^(input|textarea|ckeditor)$}
	:public method input {{-fa ""} {-type "input"} {-size ""} {-options ""} {-multiple:boolean false} --  name  {tags ""}} {
	
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]
		set data [my getData $name $id]

		if {[lsearch  "textarea ckeditor markdown datepicker" $type] != -1} {
			set input [${:bhtml} $type -placeholder $itemname -id $id  $id   $data]	
		} elseif {$type  =="select2"} {
			set input [${:bhtml} select2 -placeholder $itemname -id $id -options $options  $id   $data $tags]	
		} elseif {$type  =="fileinput"} {
			set input [${:bhtml} fileinput -placeholder $itemname -id $id  -options $options -multiple $multiple $id   $data ]	
		} else {
			if {$fa != ""} {
				set input [${:bhtml} button -fa $fa -type $type -placeholder $itemname -id $id -name $id $data]
			} else {
				set input [${:bhtml} input -htmlOptions $options -type $type -placeholder $itemname -id $id $id $data]
			}
		}
		
		#INLINE SPACING WILL NOT BE GOOD, untill this is fixed, only inlinex
		if {${:formType} == "horizontal" || ${:formType} == "inlinex"} { 
			set input [${:bhtml} htmltag -htmlOptions [list class [list col-sm-${:inputSize}]] div $input ]	
		} 			
		if {$size != ""} {
			set input [${:bhtml} htmltag -htmlOptions [list class "$size"] div $input ]	
		}
		append :${:form} $input
	}


	:public method  slider {{-sliderid "allslider"} {-min 0} {-max 100 }  {-step 1} --  name {value 0} {secondval ""}} {
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]
		set data [my getData $name $id]
		if {$value == 0} { set value $data }

		set input [${:bhtml} slider  -sliderid $sliderid -min $min -max $max -step $step $name $value $secondval]
		append :${:form} $input
	}

	#TODO label 
	:public method checkbox {name args} {
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]
		set data [my getData $name $id]
		if {$args == ""} {
			set args [list $data $itemname]
		}

		set input [${:bhtml} checkbox -id $id $id {*}$args]
		append :${:form} $input
	}
	
	#TODO label + multi
	:public method radio { {-inline 0} name args} {
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]
		set data [my getData  $name $id]
		if {$args == ""} {
			set args [list $data $itemname]
		}

		set input [${:bhtml} radio -inline $inline -id $id $id {*}$args]
		append :${:form} $input
	}

	:public method toggle {args} {
		set name [lindex $args end]
		set itemname [${:model} getAlias $name]
		set id [${:model} classKey $name]
		set data [my getData  $name $id]

		set args [lreplace $args end end $id]
		set toggle "&nbsp; "
		append toggle [${:bhtml} toggle -id $id -data $data {*}$args ]

#	$f add 	[${:bhtml} toggle -size normal -ontype danger -offtype success [mc "Expense"] [mc "Income"] goldbag_$field] 
		append :${:form} $toggle
	}

	:public method submit {{-fa ""} {-btnType primary}  -- text {type xsubmit} {class "" }}  {

		#NOD.js has problems if the name is submit, so renamed to xsubmit
		if {$fa == ""} {
			set input [${:bhtml} input  -class [list btn btn-$btnType {*}$class ]  -type submit $type $text]
		} else {
			set input [${:bhtml} button -fa $fa -class [list btn btn-$btnType {*}$class ]  -type submit -name $type $text]
		}
			if {${:formType} == "horizontal" } { 
				set input [${:bhtml} htmltag -htmlOptions [list "class" "col-sm-offset-${:labelSize} col-sm-${:inputSize}"] div $input ]	
			} 	elseif {${:formType} == "inline"} {
				set input [${:bhtml} htmltag -htmlOptions [list "class" "form-group col-sm-offset0 "] div $input ]	
			}	
		append :${:form} $input 
	}

	:public method label {{-showInline 0} {-fa ""} --  name  {size ""}} {
		if {${:formType} == "horizontal"} { 
			set class "col-sm-${:labelSize}" 
		} elseif {${:formType} == "inline"} { 
			set class ""
			if {!$showInline} {
				set class "sr-only"
			}
		} else { set class "" }
		if {$size != ""} {
			set class $size
		}
		#Verify if it's required.. if yes, then put red * next to name
		set req ""
		if {[${:model} existsValidation $name required]} {
			set req [${:bhtml} tag -htmlOptions [list class required] span *]	
		}
		if {$fa != ""} {
			set fa [${:bhtml} fa $fa]
		}
		append :${:form} [${:bhtml} label -class $class -for [${:model} classKey $name]  "$fa [${:model} getAlias $name] $req"]
	}

	:public method getDataForName {name} {
		set id [${:model} classKey $name]
		return [:getData $name $id ]
	}
	:public method getData { name id} {
		if {![${:model} loaddata]} { return  "" }
		#If query exists.. get info.. otherwise set model data
		if {[ns_queryget $id] != ""} {
			set data [ns_escapehtml [ns_queryget $id]]
		#	set data [ns_queryget $id]
		} else { 
			#ns_escapehtml here too!
			set data [ns_escapehtml [${:model} get $name]]
		}
		return $data
	
	}

	:public method captcha {{type image}} {
			switch $type {
				image { :captchaImage  }
				css { :captchaCss }
				default { :captchaImage }
			}
	}

	:method captchaImage {} {
		set field captcha

		my beginGroup 
		my label $field
		my add [${:bhtml} img /user/captcha]
		my add [mc "Enter the text in the image you see below"]
		my input  $field 

		my errorMsg $field
		my endGroup $field 
	}

	:method captchaCss {} {
		set field nameDetails

		my beginGroup 
		my label $field
		my add [mc "If you see this field, do not enter any name. Just leave empty"]
		my add [${:bhtml} input -type input -placeholder "enter your name" -id nameDetails name ]
		my errorMsg $field
		my endGroup -class "sr-only" $field 
	}
	
	:public method errorMsg {name} {
		set thiserror ""
		foreach err [${:model} getErrorsFor $name] {
			lappend thiserror $err 	
		}
		if {$thiserror != ""} {
			set errorlabel [${:bhtml} errorMsg -type danger  [join $thiserror]]
			if {${:formType} == "horizontal"} { 
				set errorlabel [${:bhtml} htmltag -htmlOptions [list class [list col-sm-offset-${:labelSize} col-sm-${:inputSize}]] div $errorlabel ]	
			} 	
			append :${:form} 	$errorlabel
		}
	}

	#This is output outside of the "form" so the size doesn't affect this one..
	:public method allErrors {} {
		#	set keys [dict keys [dict get $attributes errors]]
		set thiserror [${:model} getErrors]
		if {$thiserror != ""} {
			set htext  [mc "Please correct the following errors:"]
			append :beforeForm [${:bhtml} alert -type danger "[${:bhtml} htmltag strong $htext]  [${:bhtml} makeList $thiserror]"]
			#append $form
		}

	}

	#TODO two(2) possibilities using version 2 
	#	1. copy everything from one var to another and switch them
	#	2. use another variable to hold the var name
	#	all subsequent calls are grouped together  in the group variable
	#	Appended to the "group" instead of form
	#	OR when using beginGroup.. just generate everything for this value..?
	:public method beginGroup {{name ""}} {
		set :form group
	}

	#	reappend everything back to form, 
	#	end the grouping
	:public method endGroup {{-class ""} {name ""}} {
	# variable form group formdata
		if {[${:model} getErrorsFor $name] != ""} {
			set type error
		} else { set type "" }
		set :form formdata		
	#	puts "endGroup type $type and group stuff $group"
		#append ${:form} [${:bhtml} formGroup -type $type $group]
		if {$type != ""} { set type [${:bhtml} returnType "has" $type]}	

		append :${:form} [${:bhtml} htmltag -htmlOptions [list class "form-group $type $class" ] div ${:group}]
		set :group ""
		#puts "ending group! $form"
	}

	#endform just return the form
	:public method endForm {args} {
		return "${:beforeForm} [${:bhtml} form {*}$args ${:formdata}]"
	}

	:public method putsModel {} {
		return [${:model} search *]
	}
}

