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
	:method updateSQL {{type model}} {
		set :table [dict get ${:attributes} table]
		set :pr_stmt [dict create]	

		if {$type == "model"} {
			:updateModelColumns
		} else  {
		#	:updateMultipleRows
		}

		set where [${:whereCriteria} getCriteriaSQL]
		set update [${:updateCriteria} getCriteriaSQL]
		
		set :pr_stmt [dict merge  [${:whereCriteria} getPreparedStatements] [${:updateCriteria} getPreparedStatements]]
		set :sql "UPDATE ${:schema}.${:table} SET $update WHERE $where "
		if {${:debug}} {
			ns_log notice "DEBUG: UPDATE SQL ${:sql} and ${:pr_stmt}"
		}
		set values  [dbi_dml -db ${:db} -bind ${:pr_stmt} ${:sql}]
		
		if {$values} {
			dict set :attributes changedValues ""
			return true
		} else {
			return false
		}
	}	

	:method updateModelColumns {} {
		set :whereCriteria [SQLCriteria new -table ${:table}]	
		set :updateCriteria [SQLCriteria new -table ${:table}]	

		set primarykey ""
		if {[dict exists ${:attributes} primarykey]} { set primarykey  [dict get ${:attributes} primarykey]		}
			
		set changedValues [dict get ${:attributes} changedValues ]

		foreach key [:getColumnsKeys] {
			#update only keys that have a value that may be saved
			if {[dict exists ${:attributes} sqlcolumns $key value]} {
				if {[dict exists ${:attributes} sqlcolumns $key save]} {
					if {![dict get ${:attributes} sqlcolumns $key save]}	 { continue }
				}
				if {[:get $key] == ""} { continue  }
				
				#Not updating the primary keys 
				if {$key in $primarykey} {
					${:whereCriteria} add -includeTable 0 $key [:get $key]
					continue
				}
				#If the current key has NOT changed due to set/incr, we don't include the update
				if {$key ni $changedValues} { continue }	
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

