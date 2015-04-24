#################################	
# SQL  Criteria/Where generator
#################################	

nx::Class create SQLCriteria -mixin [list SQLCommands] {	

	:property -accessor public {table ""}

#	:property {statementType:choice,arg=default|numeric|random numeric}
#	:variable statementCount 0
	:property {where ""}

	:method init {} {
		set :where_sql ""
		set :pr_stmt ""
		#Used for in conditional operators

		if {${:table} ==""} {
			set table [dict get ${:attributes} table]
		}

		if {${:where} != ""} {
			:add {*}${:where}
		}
	}
	
	:public method add {{-fun default} {-cond "AND"} {-op =} column {value ""}} {
		set method [string tolower $fun]
		set cond [string toupper $cond]
		if {[:info lookup method $method] == ""} {
			set method default
		}
		
		:$method -cond $cond -op $op  $column $value
	#	incr :statementCount
	}

	:public method addUpdateCriteria {column value} {
		:default -op = -cond ", " $column $value
	}

	:public alias addUpdate [:info method handle addUpdateCriteria]
	
	#AND / OR supported .. 
	#TODO AND NOT etc
	:method default { -cond  -op  column {value ""}} {
		if {$value == ""} { set value [:get $column] }  
		set condition [:getCondition $cond]
		set statement [:genStatement $column $value]
		append :where_sql "$condition  ${:table}.$column $op :$statement "
	}
	
	#Generates relationships (no statements added, so it's safe to just return the sql)
	:public method addRelation { -cond  -op  {-table ""} {-fk_table ""} column fk_column } {
		set condition [:getCondition $cond]

		if {$table != ""} {
			append table .
		}
		if {$fk_table != ""} {
			append fk_table .
		}

		append :where_sql  [format "%s %s%s %s %s%s " $condition $table $column $op $fk_table $fk_column] 
		incr :statementCount
	}

	:public method subcriteria {{-cond "AND"} subcriteria } {
		set condition [:getCondition $cond]
		append :where_sql "$condition ([$subcriteria getCriteriaSQL]) "
		set :pr_stmt  [dict merge [:getPreparedStatements]	[$subcriteria getPreparedStatements]]
		#	incr :statementCount
	}
	

	#in multiple..
	:method in {-cond -op column values} {
		set fi 1
		set in_statement ""
		#TODO in_statement could be simple values 
		foreach value $values {
			set operator [expr {$fi==1? "" : ","}]
			set statement [:genStatement -type numeric $column $value]
			append in_statement $operator :$statement 
			incr fi
		}	

		set condition [:getCondition  AND]

		append :where_sql "$condition ${:table}.$column IN ($in_statement) "
	}

	#TODO solution for multiple betweens within the select
	:method between {-cond -op column value} {
		set condition [:getCondition AND]

		foreach {between_start between_end} $value { }
		set between_start_statement [:genStatement -type numeric $column $value]
		set between_end_statement [:genStatement -type numeric $column $value]
		append :where_sql "$condition ${:table}.$column BETWEEN :$between_start_statement AND :$between_end_statement "
	}

	:public method getCriteriaSQL {} {
		return ${:where_sql}
	}

	:public method getPreparedStatements {} {
		return ${:pr_stmt}
	}

}

