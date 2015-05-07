#################################	
# SQL Update 
#################################	

nx::Class create SQLUpdate -mixin [list SQLCommands]  {

	#	#Update and if empty insert?
	#	WITH upsert AS ($upsert RETURNING *) $insert WHERE NOT EXISTS (SELECT * FROM upsert);
	#
	:public method update {} {
		:updateSQL model
	}
#TODO 	{type:choice,arg=model|multi model}
	:method updateSQL {type model} {
		set table [dict get ${:attributes} table]
		set :pr_stmt [dict create]	

		if {$type == "model"} {
			:updateModelColumns
		} else  {
			:updateMultipleRows
		}

		set where [${:whereCriteria} getCriteriaSQL]
		set update [${:updateCriteria} getCriteriaSQL]
		
		set :pr_stmt [dict merge  [${:criteria} getPreparedStatements] [${:updateCriteria} getPreparedStatements]]
		set sql "UPDATE $table SET $update WHERE $where "
		set values  [dbi_dml -db ${:db} -bind ${:pr_stmt} ${:sql}]
		
		if {$values} {
			return true
		} else {
			return false
		}
	}	

	:method updateModelColumns {} {
		set :whereCriteria [SQLCriteria new -table $table]	
		set :updateCriteria [SQLCriteria new -table $table]	

		set primarykey ""
		if {[dict exists ${:attributes} primarykey]} { set primarykey  [dict get ${:attributes} primarykey]		}
			
		foreach key [:getColumnsKeys] {
			#update only keys that have a value that may be saved
			if {[dict exists ${:attributes} sqlcolumns $key value]} {
				if {[dict exists ${:attributes} sqlcolumns $key save]} {
					if {![dict get ${:attributes} sqlcolumns $key save]}	 { continue }
				}

				#Not updating the primary keys 
				if {$key in $primarykey} {
					${:whereCriteria} add $key [:get $key]
					continue
				}
				
				${:updateCriteria} addUpdateCriteria $key [:get $key]
			} 
		}
	}

	:public method updateMultipleRows {updateCriteria:object,type=SQLCriteria whereCriteria:object,type=SQLCriteria} {
		set :updateCriteria $updateCriteria
		set :whereCriteria $whereCriteria
		:updateSQL multi
	}

}

