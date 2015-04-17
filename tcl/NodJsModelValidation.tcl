##########################################
#NodJs plugin for Model using javascript verification  before submitting
##########################################
nx::Class create NodJsModelValidation {  
	:public method nodjsRules {bhtml} {
		if {![$bhtml existsPlugin nodjs]} {
			$bhtml addPlugin nodjs { js "/js/nod.js" js-min "/js/nod.min.js"  }
		}
		#This is the same as the validate.. but we create JavaScript rules for NOD
		foreach column [dict keys [dict get ${:attributes} sqlcolumns]] {
		#	set columnerrors ""; set errors "1"
			if {![dict exists ${:attributes} sqlcolumns $column validation]} { continue }
			foreach {valid rule} [dict get ${:attributes} sqlcolumns $column validation] {
				append metrics  [my nodjsValidate $valid $rule $column]
			}
		}
		#NodJS was built primarily for bootstrap 2.x, this modifications make it function in 3.x
		set metrics "var metrics = \[ \n $metrics \n ];"
		set options {
			var options = {
				'helpSpanDisplay':'help-block',
				'groupSelector':'.form-group',
				'groupClass':'has-error',
				'successClass':'has-success',
				'silentSubmit':false,

			};
		}
		set initNod [format {$('#%s').nod(metrics,options);} [string tolower [dict get ${:attributes} table]]]
		$bhtml js "$options \n $metrics  \n $initNod"
	}

	#TODO FIX THIS!
	#rule is not working as expected
	:public method  nodjsValidate {valid validation column} {
		set column_name [my getAlias $column]
		if {[dict exists $validation rule]} {
			set rule [dict get $validation rule]
		}
		#	set value [dict get ${:attributes} sqlcolumns $column value]
		set new_rule ""
		switch -- $valid  {
			required {  set msg [msgcat::mc "%s is required and cannot be empty" $column_name] ; set new_rule presence  }
			not {  set msg  [msgcat::mc {%1$s must not be %2$s}  $column_name $rule] ; set new_rule "not:${rule}"  }

			exact {  set msg [msgcat::mc {%1$s must be exactly %2$s}  $column_name $rule]  ; set new_rule "exact:${rule}"  }

			match  { 
				set msg 	[msgcat::mc "This doens't match what is required.."]; set new_rule "/$match/"  
			}
			email { 		set msg [msgcat::mc "%s must contain a valid e-mail address." $column_name]; set new_rule email 	}
			in {

			#TODO not implemented javascript side yet.. to do!
				return ""
				set match 0
				foreach val $rule {
				#	puts "in $val $value"
					if {[string match -nocase ${val} [string trim $value]]} { incr match 1 ; break }	
				}
				if {!$match} {return  	[msgcat::mc {%1$s must be one of the following: %2$s} $column_name [join $rule {; }]]  }
			}
			max-length { set msg 	[msgcat::mc {%1$s is too long (maximum %2$s characters)  }  $column_name $rule] ; set new_rule "max-length:${rule}" }
			min-length { set msg 	[msgcat::mc {%1$s must be at least %2$s characters long}  $column_name $rule] ; set new_rule "min-length:${rule}" }
			exact-length { set msg 	[msgcat::mc {%1$s must be smaller than %2$s}  $column_name $rule] ; set new_rule "exact-length:${rule}" }
			between {
				foreach {min max} $rule { }
				set msg 	[msgcat::mc {%1$s must be between %2$s and %3$s characters long} $column_name $min $max $rule] ; set new_rule "between:${min}:${max}" 
			}
			min-num { set msg 	[msgcat::mc {%1$s must be bigger than %2$s} $column_name $rule] ; set new_rule "min-num:${rule}" }
			max-num { set msg  	[msgcat::mc {%1$s is too long (maximum %2$d characters)}  $column_name $rule] ; set new_rule "max-num:${rule}" }
			between-num {
				foreach {min max} $rule { }
				set msg  	[msgcat::mc {Must be between number between %1$s and %2$s}  $column_name $min $max] ; set new_rule "between-num:${min}:${max}" 
			}
			integer { set msg [msgcat::mc "%s must be an integer"  $column_name ] ; set new_rule "integer"  }
			numerical {set msg [msgcat::mc "%s must be a number"  $column_name ] ; set new_rule float  }
			same-as { set msg 	[msgcat::mc {%1$s must be same as %2$s. These two fields don't seem too match}  $column_name $rule] ; set new_rule "same-as:#${rule}" }
			one-of {  }
			default {
				return ""
			}

		}
		set msg [ns_quotehtml $msg]
		set selector [my classKey $column]
		return [format "\t \[ '#%s', '%s', '%s' \],\n" $selector $new_rule $msg]

	}
}
