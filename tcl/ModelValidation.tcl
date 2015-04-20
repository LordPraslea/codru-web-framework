##########################################
# Model Validation  
##########################################

nx::Class create ModelValidation {

	#	Model validation. We control if Errors == 0 then no errors occured
	#	Otherwise we have a list
	#	TODO simplification needed for unsafe values
	:public method validate {{onecolumn ""}} {
		set errors "0";
		if {$onecolumn != ""} {
			set columns $onecolumn	
		} else {
			#set columns [dict keys [dict get ${:attributes} sqlcolumns]] 
			#dict get ${:attributes} scenarios $this_scenario safe
			#
			# Look at scenario and get good columns
		if 	{[dict exists ${:attributes} scenarios all safe]} {
			set all [dict get ${:attributes} scenarios all safe]
		} else { set all "" }
			if {[dict exists ${:attributes} scenarios [my getScenario] safe]} {
				set columns [dict merge [dict get ${:attributes} scenarios [my getScenario] safe] $all]
			} else { set columns $all }
		}
		
		:validateColumns

		if {[dict exists ${:attributes} errors]} {
			set errors [dict get ${:attributes} errors]
		}
		return  $errors
	}

	:method validateColumns {} {
		upvar columns columns
		#If validating all of them..use columns otherwise ev = empty value .. for when getting scenarios 
		foreach {column ev} $columns  {
			set columnerrors "";
			if {![dict exists ${:attributes} sqlcolumns $column validation]} { continue }
			foreach {valid extra} [dict get ${:attributes} sqlcolumns $column validation] {
				if {[dict exists $extra on]} {
					set on [dict get $extra on]
			#		#If the scenario doesn't need validation.. just return
					if {[my getScenario] ni $on && $on != "all"} {  
						continue 
					}
				}
				set currentColumnError [my switchValid $valid $extra $column]
				if {$currentColumnError != 0} { lappend columnerrors $currentColumnError 	}
			}
			if {[join $columnerrors] != ""} {
				dict set :attributes errors $column $columnerrors
			}
		}
	}

	#This function validates the attributes before saving in the database
	:public method switchValid {valid extra column} {
		set column_name [my getAlias $column]
		if {![dict exists ${:attributes} sqlcolumns $column value]}  { return "$column has no value set"  }
		set value [dict get ${:attributes} sqlcolumns $column value]
		if {[dict exists $extra message]} {
			set message [dict get $extra message]
		}
		if {[dict exists $extra rule]} {
			set rule [dict get $extra  rule]
		}
		
		if {[set r [:$valid $extra $column $value]] != 0} {
					return $r
		}

		return 0
	}

	:method required {extra column value} {
		if {$value == ""} { return [msgcat::mc "%s is required" $column_name] }
	}

	:method string {extra column value} {
		if {0} { return "$column_name must be a string" }
	}

	:method not {extra column value} {
		if {[string match $value $rule]} { return [msgcat::mc {%1$s must not be %2$s} $column_name $rule]   }
	}

	:method exact {extra column value} {
		if {![string match $value $rule]} { return  [msgcat::mc {%1$s must be exactly %2$s} $column_name $rule]   }
	}

	:method match {extra column value} {
		if {![regexp $rule $value]} { return [msgcat::mc "This doens't match what is required.."] }

	}

	:method email {extra column value} {
		set regexp {^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$}
		if {![regexp $regexp $value]} { return [msgcat::mc "%s must contain a valid e-mail address." $column_name]  }

	}

	:method in {extra column value} {
		set match 0
				foreach val $rule {
					if {[string match -nocase ${val} [string trim $value]]} { incr match 1 ; break }	
				}
				if {!$match} {return [msgcat::mc {%1$s must be one of the following: %2$s} $column_name [join $rule "; " ] ] }

	}

	:method max-length {extra column value} {
		if {[string length $value] > $rule} { return [msgcat::mc {%1$s is too long (maximum %2$s characters)} $column_name $rule] }
	}

	:method min-length {extra column value} {
		if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be at least %2$s characters long} $column_name $rule] }
	}

	:method exact-length {extra column value} {
		if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be exactly %2$d characters long} $column_name $rule] } 
	}

	:method between {extra column value} {
		foreach {min max} $rule { }
		if {[string length $value] > $max || [string length $value] < $min} {
			return [msgcat::mc {%1$s must be between %2$s and %3$s characters long} $column_name $min $max ]  
		}
	}

	:method integer {extra column value} {
		if {![string is integer $value]} { return [msgcat::mc "%s must be an integer" $column_name] } 
	}

	:method numerical {extra column value} {
		if {![string is double $value]} { return [msgcat::mc "%s must be a number" $column_name] } 
	}

	:method min-num {extra column value} {
		if {$value < $rule } { return [msgcat::mc {%1$s must be bigger than %2$s} $column_name $rule] }
	}

	:method max-num {extra column value} {
	 if {$value > $rule } { return [msgcat::mc {%1$s must be smaller than %2$s} $column_name $rule] } 
	}

	:method between-num {extra column value} {
		foreach {min max} $rule { }
		if {$min > $value || $max < $value} {
			return [msgcat::mc {%1$s must  be between number between %2$s and %3$s} $column_name $min $max] 
		}
	}

	:method same-as {extra column value} {
		if {![string match [my get $column] [my get $rule]]} {
			return [msgcat::mc {%1$s must be same as %2$s. These two fields don't seem too match}  $column_name $rule]
		}
	}

	:method one-of {extra column value} {
	
	}
	#unsafe?

	#This is how you implement the default from the previous function
	:public method unique {extra column value} {
		#Verify if the column is unique
		if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set column_name [my getAlias $column]
		if {[my findByCond -save 0 [list $column $value] ]} {
			return [msgcat::mc 	{%1$s must be unique. There already exists someone who uses %2$s}	 $column_name $value] 
		
		}
		return 0
	}

	:public method captcha {extra column value} {
		if {![string match -nocase $value [ns_session get humanTest]]} {
			return [msgcat::mc 	{The code you've entered is incorrect, try again.}] 
		}
		:unset captcha
		return 0
	}

}
