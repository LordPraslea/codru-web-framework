#################################	
# SQL Commands 
# 	Functions used in all sub SQL functions:
# 		SQLSelect
# 		SQLInsert
# 		SQLUpdate
# 		SQLRecycle (Delete, Restore RecycleBin)
# 		SQLCriteria ?
#################################	
::nx::Slot method type=choice {name value arg} {
  if {$value ni [split $arg |]} {
    error "Value '$value' of parameter $name not in permissible values $arg"
  }
}

nx::Class create SQLCommands   {

#Statement Type 
#	Used for collision avoidance with prepared statements
# numeric = column name + statementCount (default)
# random = column name + random code for each column
	#:property {statementType:choice,arg=default|numeric|random numeric}
	:property {statementType numeric}
	:variable statementCount 0

	:method getSeparator {cond} {
		set condition [expr {${:columnCount} == 0 ? "" : "$cond"}]
		incr :columnCount
		return $condition
	}

	#TODO upvar condition ?:)
	:method getCondition {cond} {
		return [expr {${:statementCount} == 0 ? "" : " $cond"}]
	}
 #TODO {-type:choice,arg=numeric|random|default default}
	:method genStatement {{-type default} column {value ""}} {
		set	statement $column  

		if {$type == "default"} {
			set type ${:statementType}	
		}
		switch -- $type {
			numeric { 	set	statement [format "%s_%s" $column ${:statementCount}] }
			random { 	set	statement [format "%s_%s" $column [generateCode 2 3] ] }
		}

		if {[dict exists ${:pr_stmt} $column]} {

		}

		#if {$value != ""} { dict set :pr_stmt $statement $value }
		 dict set :pr_stmt $statement $value 
		incr :statementCount
		return $statement
	}

	:method genStmt {args} {
		return [:genStatement {*}$args]
	}

	#:public alias genStmt [:info method handle genStatement]


}
