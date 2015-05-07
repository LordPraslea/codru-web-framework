#################################	
# SQL Recycle (Delete + Restore) 
#################################	

nx::Class create SQLRecycle -mixin [list SQLCommands]  {
#
	# This function selects the data that has to be deleted
	# Saves it using the RecycleBin mechanism, then deletes it
	# TODO make function to select by using primary key's
	#
	#TODO view if limit empty and if only a number, view if offset is a number..
	#
	:public method delete { {-recycle 1}  } {
		set pr_stmt ""
		if {$table == ""} { 		set table [dict get ${:attributes} table] }
		set deleteCriteria [SQLCriteria new -table $table]

		set recycleID	[:recycleBin 1]

		#COMPUTE ALL PRIMARY KEYS
		foreach id [dict get ${:attributes} primarykey] {
			$deleteCriteria add $id [:get $id]	
		}

		set status [:runDeleteSQL $table $deleteCriteria]
	
		if {$recycle} {
			return $recycleID 
		}
		return $status
	}
	
	#Warning, this deletes things from table based on deleteCriteria for good! no recycling!
	:public method deleteOther {{-table } {-deleteCriteria:object,type=SQLCriteria}} {
		return [:runDeleteSQL $table $deleteCriteria]
	
	}

	:method runDeleteSQL {table deleteCriteria} {
		set where_sql [$deleteCriteria getCriteriaSQL]
		set pr_stmt [dict merge $pr_stmt [$deleteCriteria getPreparedStatements]]

		set sql "DELETE FROM $table WHERE $where_sql"
		set status [dbi_dml -db ${:db} -bind $pr_stmt $sql]
		return $status
	}

	#TODO save foreign keys... delete them also
	:method recycleBin {recycle} {
		if {$recycle} {
			set recycled ""	
			foreach key	[:getColumnsKeys]  {
				if {[dict exists ${:attributes} sqlcolumns $key value]} {
					if {![dict exists ${:attributes} sqlcolumns $key nosort]} {	
						lappend recycled $key [:get $key]
					}
				}
			}

			set recycleBin [RecycleBin new]
			$recycleBin set deleted_at [getTimestamp] table_name $table data $recycled user_id [ns_session get userid]
			if {![$recycleBin save]} {
				error "Could not save RecycleBin: [my getErrors]"  
			}
			return  [$recycleBin get id]
			
		}
	}
		
		# This method restores the data from the RecycleBin table
		# Returns if succeeded or not
		#
		#TODO extensive RBAC verification?
	:public method restore {id} {
		set recycleBin [RecycleBin new]

		if {[$recycleBin findByPk $id]} {
			if {![$recycleBin get user_id] == [ns_session get userid]}  {
				:addError [mc "Only the user who deleted this may restore it."]
				return false
			}
			foreach {key value} [$recycleBin get data] {
				:set $key $value
			}
			set save [:save]

			#Delete this..
			if {$save} {
				$recycleBin delete -recycle 0 
			}
			return $save
		}

		return false
	}
}
