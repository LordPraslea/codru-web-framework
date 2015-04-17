##########################################
# Model Validation  
##########################################

nx::Class create ModelValidation {
	:public method validate {{onecolumn ""}} {
		#
		#	Model validation. We control if Errors == 0 then no errors occured
		#	Otherwise we have a list
		#	TODO simplification needed for unsafe values
		#
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
		#	puts "Ok for $columns"
		}
		#If validating all of them..use columns otherwise ev = empty value .. for when getting scenarios 
		foreach {column ev} $columns  {
			set columnerrors "";
			#TODO Errors set to 0 meaning there are no errors.. this was 1, maybe change to "" (empty string?)
			if {![dict exists ${:attributes} sqlcolumns $column validation]} { continue }
			foreach {valid extra} [dict get ${:attributes} sqlcolumns $column validation] {
			#if this isn't for the scenario.. just skip it alltogether
				if {[dict exists $extra on]} {
					set on [dict get $extra on]
			#		#If the scenario doesn't need validation.. just return
					if {[my getScenario] ni $on && $on != "all"} {  
					#	puts "Shouldn't verify if $column is valid"
						continue 
					}
				}
			#TODO verify if switchValid is empty..don't add text, if not empty go to next one(we already have something wrong..)
				set err [my switchValid $valid $extra $column]
				if {$err != 0} { lappend columnerrors $err	}
				#lappend columnerrors [my switchValid $valid $extra $column]
			}
			if {[join $columnerrors] != ""} {
				dict set :attributes errors $column $columnerrors
			}
		}
		if {[dict exists ${:attributes} errors]} {
			set errors [dict get ${:attributes} errors]
		}
		return  $errors
	}




	:public method switchValid {valid extra column} {
		#This function validates the attributes before saving in the database
		set column_name [my getAlias $column]
		#This isn't usually needed since value is always EMPTY
		if {![dict exists ${:attributes} sqlcolumns $column value]}  { return "$column has no value set"  }
	#puts "switchvalid for $column  $valid $extra"
		set value [dict get ${:attributes} sqlcolumns $column value]
	#	puts "validating $valid for $column extra $extra and current value $value"
		if {[dict exists $extra message]} {
			set message [dict get $extra message]
		}
		if {[dict exists $extra rule]} {
			set rule [dict get $extra  rule]
		}
	
		switch -- $valid  {
			required {if {$value == ""} { return [msgcat::mc "%s is required" $column_name] } }
			string { if {0} { return "$column_name must be a string" } }
			not { if {[string match $value $rule]} { return [msgcat::mc {%1$s must not be %2$s} $column_name $rule]   } }
			exact { if {![string match $value $rule]} { return  [msgcat::mc {%1$s must be exactly %2$s} $column_name $rule]   } }

			match  {
				#TODO this
				if {![regexp $rule $value]} { return [msgcat::mc "This doens't match what is required.."] }
			}
			email { 
				set regexp {^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$}
				if {![regexp $regexp $value]} { return [msgcat::mc "%s must contain a valid e-mail address." $column_name]  }
			}
			in {
				set match 0
				foreach val $rule {
					if {[string match -nocase ${val} [string trim $value]]} { incr match 1 ; break }	
				}
				if {!$match} {return [msgcat::mc {%1$s must be one of the following: %2$s} $column_name [join $rule "; " ] ] }
			}
			max-length { if {[string length $value] > $rule} { return [msgcat::mc {%1$s is too long (maximum %2$s characters)} $column_name $rule] } }
			min-length { if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be at least %2$s characters long} $column_name $rule] } }
			exact-length { if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be exactly %2$d characters long} $column_name $rule] }  }
			between {
				foreach {min max} $rule { }
				if {[string length $value] > $max || [string length $value] < $min} {
					return [msgcat::mc {%1$s must be between %2$s and %3$s characters long} $column_name $min $max ]  
				}
			}
			integer { if {![string is integer $value]} { return [msgcat::mc "%s must be an integer" $column_name] }  }
			numerical { if {![string is double $value]} { return [msgcat::mc "%s must be a number" $column_name]
				} }
			min-num { if {$value < $rule } { return [msgcat::mc {%1$s must be bigger than %2$s} $column_name $rule] } }
			max-num { if {$value > $rule } { return [msgcat::mc {%1$s must be smaller than %2$s} $column_name $rule] } }
			between-num {
				foreach {min max} $rule { }
				if {$min > $value || $max < $value} {
					return [msgcat::mc {%1$s must  be between number between %2$s and %3$s} $column_name $min $max] 
				}
			}
			length { 
			#TODO remove this in the near future because we're using min-length exact-length ..etc
				foreach {k v} $rule {

					switch -- $k  {
						min { 
							if {[string length $value] < $v} { return [msgcat::mc {%1$s must be at least %2$d characters long} $column_name $v]} 
						}
						max {
							if {[string length $value] > $v} { return [msgcat::mc {%1$s is too long (maximum %2$d characters)} $column_name $v] 
							}
						}	
					}
				}
			}
			same-as { 
				if {![string match [my get $column] [my get $rule]]} {
					return [msgcat::mc {%1$s must be same as %2$s. These two fields don't seem too match}  $column_name $rule]
				}
			}
			one-of {  }
			unsafe { 
				#Removed from here because there was a PROBLEM with this implementation:
				#say we want to save manually, this WON'T allow us!
			}
			default {
				#Default means either it doesn't exist or it's a programmable function of this model
				#RULE may contain different things..
				#It can even select from the database.. view if a file exists.. Verify if today is a special date..
				if {[set r [my $valid $extra $column $value]] != 0} {
					return $r
				}
				if {0} {
					#This is how you implement it..
					:public method verifyFirstname {rule column value} {
						puts "Verifying custom FirstName $rule"
						set column_name [my getAlias $column]
						if {![string match -nocase andrei $value]} {
							return "$column MUST be Andrei!"	
						}
						return 0
					}
				}
			}

		}
		return 0
	}

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
