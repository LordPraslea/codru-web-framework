#################################	
# SQL Generator 
#################################	

#TODO change to NOT extend from sqlrelations
nx::Class create SQLGenerator -superclass [SQLRelations]  {

	#  Search one row by any conditions .
	:public method findByCond {{-numericStmt 0} {-relations 0} {-save 1} conditions } {
		set first 0
		set table [dict get ${:attributes} table]
		set pr_stmt ""
		set toSelect "*"
		set from "$table "
		set where_sql ""

		if {$relations} {	
		
				set computeRelations [my computeRelations $toSelect $table $first]

				set toSelect [dict get $computeRelations toSelect]
				set first [dict get $computeRelations first]
				append where_sql [dict get $computeRelations where_sql]
				append from [dict get $computeRelations from]
		}

			set computewhere [my computeWhere $conditions $first 1 $table] 
		
		append where_sql [dict get $computewhere where_sql]
		set pr_stmt [dict merge $pr_stmt [dict get $computewhere pr_stmt]]
		if {$toSelect != "*"} {
			set first 0
			set selectList $toSelect
			set toSelect ""
			foreach ts $selectList {
				set what [expr {$first==0? "" : ", "}]
				append toSelect $what $ts 
				incr first
			}
		}
		set sql_select "SELECT $toSelect FROM $from WHERE $where_sql"
#	puts "sql_select $sql_select"	
		 #true if it exists, false if it doesn't exist(nothing is found)
		 set result [dbi_0or1row -db ${:db} -array data -bind $pr_stmt $sql_select ]
		 if {$save} {
			 foreach {key val} [array get data] {
			 #Verifying if it exists is useless,since it surely exists because 
			 #the * returns the correct column names..
			#TODO add only the ones that exist as a sqlcolumn.. however maybe you select something that doesn't exist..?
				my set $key $val
			 }
			 #Isn't a new record anymore..
			 set :newRecord 0
			 set :scenario update 
		 }
		return $result
	}

	#TODO make multiple primary keys
	:public method findByPk {{-relations 0} {-save 1} -- id } {
		#Givnig ARGS.. dict with key value (name of pk, value of pk)
		set table [dict get ${:attributes} table]
		dict set pr_stmt id $id
		set from $table
		set toSelect "*"
		set first 0
		set where_sql ""

		if {$relations} {	

				set computeRelations [my computeRelations $toSelect $table $first]

				set toSelect [dict get $computeRelations toSelect]
				set first [dict get $computeRelations first]
				append where_sql [dict get $computeRelations where_sql]
				append from [dict get $computeRelations from]
				if {$toSelect != "*"} {
				#	set toSelect [dict get $info sqlcolumns $toSelect]
				#
					set first 0
					set selectList $toSelect
					set toSelect ""
					foreach ts $selectList {
						set what [expr {$first==0? "" : ", "}]
						append toSelect $what $ts 
						incr first
					}
				}
		}
		if {$where_sql != ""} { append where_sql " AND " }
		append where_sql " $table.id=:id "
		set sql_select "SELECT $toSelect FROM $from WHERE $where_sql"
		#	ns_puts "SqlSelect $sql_select"
		 set result [dbi_0or1row -db ${:db} -array data -bind $pr_stmt $sql_select ]
		 if {$save} {
			 foreach {key val} [array get data] {
			 #Verifying if it exists is useless,since it surely exists because 
			 #the * returns the correct column names..
				my set $key $val

				 #Isn't a new record anymore..
			 }
			 set :newRecord 0
			 set :scenario update
		 }
		 #true if it exists, false if it doesn't exist
		return $result
	}


	


	:public method search {{-numericStmt 0} {-relations 0} {-table ""} {-limit ""}  {-offset ""}
				 {-where ""} {-order ""} {-orderType asc} {-selectSql ""} {-pr_stmt ""} -- {toSelect *}} {
		# Function that searches for multiple data in the database..
		#TODO differentiate between 1 row (set object) and many (return values)
		 #TODO prstmt not used yet.. could be used with selectSql
		 #TODO view if limit empty and if only a number, view if offset is a number..
		 #	puts "Search with args: \n $args \n"
		set first 0
		set where_sql ""
		set from ""
		if {$table == ""} {
			set table [dict get ${:attributes} table]
		}
	if {$selectSql == ""} {
		set from $table
		set oldSelect $toSelect

		if {$relations} {
			if {$toSelect == "*"}	 {
				#TODO NOT WORKING
				set toSelect "${table}.*" 
				set computeRelations [my computeRelations $toSelect $table $first]

				set toSelect [dict get $computeRelations toSelect]
				set first [dict get $computeRelations first]
				append where_sql [dict get $computeRelations where_sql]
				append from [dict get $computeRelations from]
			} else {
			#	set toSelect ""
			 set computeRelations [my computeRelations $toSelect $table $first]

				set toSelect [dict get $computeRelations toSelect]
				set first [dict get $computeRelations first]
				append where_sql [dict get $computeRelations where_sql]
				append from [dict get $computeRelations from]
			#	puts "toselect $toSelect $first where_sql $where_sql and from $from"
			}

		}
	#	puts "computerelations $computeRelations"
	#	set pr_stmt [dict create]	
		set computewhere [my computeWhere $where $first $numericStmt $table] 
		append where_sql [dict get $computewhere where_sql]
		set pr_stmt [dict merge $pr_stmt [dict get $computewhere pr_stmt]]
		
		#TODO ns_parseargs :)
		if {$toSelect != "*"} {
		#	set toSelect [dict get $info sqlcolumns $toSelect]
		#
			set first 0
			set selectList $toSelect
			set toSelect ""
			foreach ts $selectList {
				set what [expr {$first==0? "" : ", "}]
				append toSelect $what $ts 
				incr first
			}
		}
		#TODO escaping .. here
	#	if {![info exists where_sql] } { set where_sql "1=1"}
		append sql_select "SELECT $toSelect "
		append sql_select "FROM $from "
		#$where
		if {$where_sql != ""} {
			append sql_select "WHERE $where_sql "
		}
	} else { set sql_select [lindex  $selectSql 0] ; set pr_stmt [lindex $selectSql 1]}
		#TODO sorting should be fixed!
		#First see if such a column exists, and if nosort isn't set..
		#Then view if this is a "relation".. if a "fk_table" exists
		#let 
		if {$order != ""} {
			#TODO using prepared statements with ORDER BY won't work..
			#need to verify manually if table exists, then order it accordingly
			set sql_order ":ordeby"
		#	dict set pr_stmt ordeby  "$table.$order $orderType" 
			#We only need the real columns, since we define a name for the relations
			#and the relations don't need table.column since they're defined in "as"
			set ordercol ""
			if {[dict exists ${:attributes} sqlcolumns $order] } {
				if {![dict exists ${:attributes} sqlcolumns $order nosort]} {
					set ordercol $table.$order 
				}
			} elseif {[dict exists ${:attributes} relations $order] } {
				if {[dict exists ${:attributes} relations $order fk_table]} {
					foreach {k v} [dict get ${:attributes} relations $order] { set $k $v }
					#	set fk_table [dict get ${:attributes} relations $order fk_table]
					#	set fk_value [dict get ${:attributes} relations $order fk_value]
					#	set column [dict get ${:attributes} relations $order column]

					set ordercol $fk_table.$fk_value
					if {[lsearch -nocase $from $fk_table] ==-1} { 
						set ordercol "$column"
					}
				} else { set order id }
			}	
			if {$ordercol != ""} {
			append sql_select " ORDER BY $ordercol $orderType " ;# $sql_order  "
			#append sql_select "ORDER BY $sql_order $orderType " ;# $sql_order  "
			} else { append sql_select " ORDER BY $order $orderType "  }
		}
		if {$limit != ""} {
			set sql_limit ":limit"
			dict set pr_stmt limit $limit 
			append sql_select " LIMIT $sql_limit "
		}
		if {$offset != ""} {
			set sql_offset ":offset"
			dict set pr_stmt offset $offset 
			append sql_select " OFFSET $sql_offset "
		}
		#set sql_statement [format $sql_select $toSelect $table $where_sql ]
		#set sql_statement [format {SELECT %s FROM %s WHERE %s} $toSelect $table $where_sql ]

		#set values  [dbi_rows -columns columns -bind $pr_stmt $sql_statement ]
	#	ns_puts "<br>Ok bind $pr_stmt with $sql_select"
		my sqlstats $sql_select
		#ns_puts "sql is $sql_select <br>"
		set values  [dbi_rows -db ${:db} -columns columns -bind $pr_stmt $sql_select ]
	#	if {$values == ""} {  return "" }
		# Returns the columns selected and the values
		return [dict create columns $columns values $values ]
	}

	:public method insert {args} {
		#
		# Insert a new record
		# TODO multi insert possibility
		#
		set table [dict get ${:attributes} table]
		set pr_stmt [dict create]	
		set first 0

		if {[llength $args] == 0} {
			foreach key [dict keys [dict get ${:attributes} sqlcolumns]] {
			#	my variable $key
			#	set val [dict get ${:attributes} sqlcolumns $key]
			#	Insert only keys that have a value
				if {[dict exists ${:attributes} sqlcolumns $key value]} {
					if {[dict exists ${:attributes} sqlcolumns $key save]} {
						if {![dict get ${:attributes} sqlcolumns $key save]}	 {  continue }
					}
				#TODO verify if you MAY add the PK yourself!
				#Not inserting the ID, we know "should be empty" but sometimes maybe you WANT to insert it yourself?
				#	if {$key == "id"} { continue }
					set what [expr {$first==0? "" : ", "}]
					#TODO figure out when you have multiple PK's.. when updating
					append columns [format "%s%s" $what $key  ]
					dict set pr_stmt $key [dict get ${:attributes} sqlcolumns $key value] 

					append insert [format "%s:%s" $what $key]

					incr first
				} 
			}
			set columns "($columns)"
			set insert "($insert)"
		} else {
			ns_parseargs {columns values}	$args
			foreach $cols $values {
				set what [expr {$first==0? "" : ", "}]
				append insert $what ('[join $cols ',']')
				incr first
			}
		}
		
	
		
		set sql "INSERT INTO $table $columns VALUES $insert "
		#If 1 or multiple primary keys, return.. otherwise don't return anything..
		if {[dict exists ${:attributes} primarykey]} {
			#TODO separate postgresql from sqlite, mysql etc
			#PostgreSQL
			append sql " RETURNING [join [dict get ${:attributes} primarykey] ,]"	
			#SQLite
			#append sql " ; SELECT last_insert_rowid() FROM $table LIMIT 1"
			set returnid [dbi_0or1row -db ${:db} -array mydata -bind $pr_stmt $sql] 
			if {$returnid == 0} { return false }
			foreach id	[dict get ${:attributes} primarykey] {
				my set $id $mydata($id)
			}
		} else {
			set values  [dbi_dml -db ${:db} -bind $pr_stmt $sql] ;
			#Inserting values with no primary key..
		}

	#	When insert succeeds we don't have  new record anymore
		set :newRecord 0
		set :scenario update ;#Set scenario to update..?
		return true ; #Everything seems allright
		
	}


	:public method update {} {
		#
		# update supporting multiple primary keys
		# TODO multi update
		#either create function updateAll or have multiple args to this one.. 
		#	if no args =  update this one..
		#	if >=1 args.. update others
		#	#Update and if empty insert?
		#	WITH upsert AS ($upsert RETURNING *) $insert WHERE NOT EXISTS (SELECT * FROM upsert);
		#
		set table [dict get ${:attributes} table]
		set pr_stmt [dict create]	
		set first 0
		set second 0
		if {[dict exists ${:attributes} primarykey]} {
			set primarykey [dict get ${:attributes} primarykey]
		} else { set primarykey ""}
		foreach key [dict keys [dict get ${:attributes} sqlcolumns]] {
		#	my variable $key
		#	set val [dict get ${:attributes} sqlcolumns $key]
		#	Update only values that have a value 
			if {[dict exists ${:attributes} sqlcolumns $key value]} {
				#TODO figure out when you have multiple PK's.. when updating
				if {[dict exists ${:attributes} sqlcolumns $key save]} {
					if {![dict get ${:attributes} sqlcolumns $key save]}	 { continue }
				}
				set what [expr {$first==0? "" : ", "}]
				dict set pr_stmt $key [dict get ${:attributes} sqlcolumns $key value] 
				#Not updating the ID
				if {$key in $primarykey} {
					set what [expr {$second==0? "" : " AND "}]
					append where "$what $key = :$key"
					incr second
					continue
				}
				append update [format "%s%s=:%s" $what $key  $key ]

				incr first
			} 
		}
		set sql "UPDATE $table SET $update WHERE $where "
		set values  [dbi_dml -db ${:db} -bind $pr_stmt $sql]
		if {$values} {
			return true
		} else {
			return false
		}
	}	
	
	:public method delete {{-numericStmt 1} {-table ""} {-in 0} {-recycle 1} -- {toDelete id}} {
		#
		# This function selects the data that has to be deleted
		# Saves it using the RecycleBin mechanism, then deletes it
		# TODO make function to select by using primary key's
		#
		#TODO view if limit empty and if only a number, view if offset is a number..
		set pr_stmt ""

		if {$table == ""} {
			set table [dict get ${:attributes} table]
		}
		#If toDelete contains more than one element (lists) you add them all.. 
			set first 0
			if {$toDelete == "id"} {
				lappend toDelete [my get id]
			}
			if {$recycle} {
			#TODO save foreign keys... delete them also
			#	set data [my findByPk $id] 
				set recycled ""	
				foreach key	[dict keys [dict get ${:attributes} sqlcolumns]] {
					if {[dict exists ${:attributes} sqlcolumns $key value]} {
						if {![dict exists ${:attributes} sqlcolumns $key nosort]} {	
							lappend recycled $key [my get $key]
						}
					}
				}

				set recyclebin [RecycleBin new]
				$recyclebin set deleted_at [getTimestamp] table_name $table data $recycled user_id [ns_session get userid]
				if {![$recyclebin save]} {
					error "Could not save RecycleBin: [my getErrors]"  

				}
				set rid [$recyclebin get id]
			}
		set computewhere [my computeWhere $toDelete $first $numericStmt $table] 
		append where_sql [dict get $computewhere where_sql]
		set pr_stmt [dict merge $pr_stmt [dict get $computewhere pr_stmt]]

		set sql "DELETE FROM $table WHERE $where_sql"

	#	puts "Deleting $sql "
		set status [dbi_dml -db ${:db} -bind $pr_stmt $sql]
	#	puts "Status is $status"
		if {$recycle} {
			 return $rid 
			
		}
		return $status
	}

	:public method recycleBin {} {
		#If :delete gets complicated, switch a part here
	}

	:public method restore {id} {
		#
		# This method restores the data from the RecycleBin table
		# Returns if succeeded or not
		#
		
		set recyclebin [RecycleBin new]
		 if {[$recyclebin findByPk $id]} {
			if {![$recyclebin get user_id] == [ns_session get userid]}  {
			#TODO RBAC?
				my addError [mc "Only the user who deleted this may restore it."]
				return false
			}
			foreach {key value} [$recyclebin get data] {
				my set $key $value
				
			}
			#Delete this..
			set save [my save]

			if {$save} {
				$recyclebin delete -recycle 0 
			}
			return $save
		}
	
		return false
	}

	
	:public method save {} {
		# Validate the model, if everything is OK, it usually returns 1.. otherwise the list of errors:)
		# If 1 and newRecord 1 it inserts, if 1 and newRecord 0 it updates
		#[llength [my validate]]>1p
		# 
		if {[my validate] !=0} {
			return 0
		} 

		#TODO beforeSave
		# TODO if insert/update returns 0, generate an error
		if {${:newRecord}} {
			return [my insert]
		} else {
			return [my update]
		}
		#TODO afterSave
		return 1
	}

	

}
