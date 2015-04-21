#################################	
# SQL Where generator
#################################	

nx::Class create SQLWhere {	

	:property -accesor public {table ""}
	:property {numericStmt 0}
	:property {first 0}
	:property {where ""}
	:property {compute 0}

	:public method add {{-cond "AND"} {-eq =} column value} {
		lappend :where [list  $column $value]
	}

	:method init {} {
		#SQLwhere extends sqlrelations ? or separate?
		if {${table} ==""} {
			set table [dict get ${:attributes} table]
		}

		set :where_sql ""
		set :pr_stmt ""
		set :statement_number 100

		if {${:where} != ""} {
			:add {*}${:where}
		}

		if {${:compute}} {
			:computeWhere
		}
	}

	:public method computeWhere {} {

		if {[llength $where] == 2 && [llength [lindex $where 0]] == 1} {
			foreach {key val} $where  { }
			dict set pr_stmt $key $val
			set what [expr {$first==0? "" : " AND"}]
			append where_sql "$what $table.$key = :$key "
		} else {

			foreach arg $where {
			#	foreach {key val} $arg  { }
				ns_parseargs {{-cond "AND"} {-eq =} -- key val} $arg

				#if {[dict exists ${:attributes} sqlcolumns $key]}  { return -code 1 "$key column doesn't exist!"}
				if {$cond == "IN"} { 
					set fi 1
					set inval ""
					foreach argin $val {
						set what [expr {$fi==1? "" : ","}]
						#	append inval $what $argin 
						append inval $what :$statemet_number 
						dict set pr_stmt $statement_number $argin
						incr statement_number 
						incr fi
					}	

					#	dict set pr_stmt $key $inval
					#	otherwise instead of $inval :$key
					#set what [expr {$first==0? "" : " $cond"}]
					set what [expr {$first==0? "" : " AND"}]

					append where_sql "$what $table.$key IN ($inval)"
				} elseif {$cond == "BETWEEN"} {
					foreach {between_start between_end} $val { }
					append where_sql "AND $table.$key BETWEEN :between_start AND :between_end"

					dict set pr_stmt between_start $between_start
					dict set pr_stmt between_end $between_end
				} else {
					if {$val == ""} { set val [my get $key] }  
					set what [expr {$first==0? "" : " $cond"}]
					if {$numericStmt} {
						set prkey $first
					} else { set prkey $key }
					append where_sql "$what  $table.$key $eq :$prkey "
					dict set pr_stmt $prkey $val
				}

				incr first
			}
		}
		return [dict create where_sql $where_sql pr_stmt $pr_stmt  ]
	}
