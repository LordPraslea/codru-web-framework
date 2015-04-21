#################################	
# Tags Model management, can be used everywhere!
#################################	

nx::Class create SQLGenerator {
	
	#	belongs_to 	foreign_key fk_id other_table other_table_id  
	#	has_one		one-to-one
	#	has_many       this_id 	other_table	other_table_id 
	#	many_many 		
	#stat(istical)
	
	# Relations selection.. 
	# #TODO MULTI PK
	:public method relations {relation {id {}}} {
		if {![dict exists ${:attributes} relations $relation]}  {
			# puts "Relation doesn't exist $relation";
			return ""
		}
		set table [:getTable]
		#Sets all the relation variables 
		foreach {k v} [dict get ${:attributes} relations $relation] { set $k $v }	
		foreach value $fk_value {
			append select  ${fk_table}.$value
		}
		
		:relationsMultipleOrSimple

		:relationsExtraColumn

		#puts "SQL for relation is $sql_select"
		if  {$id == ""} {
			dict set pr_stmt column [my get $column]
		} else { dict set pr_stmt column $id }

		my sqlstats $sql_select
		set values  [dbi_rows -db ${:db} -columns columns -bind $pr_stmt $sql_select ]
		dict set :attributes relations $relation value $values

		return $values
	}
	
	#This function allows you to specify standard select data for relations
	#using the fk_extra { column value } option in a model
	:method relationsExtraColumn {} {
		foreach refVar {relation fk_extra fk_table sql_select} { :upvar $refVar $refVar }

		set where_extra ""
		if {[dict exists ${:attributes} relations $relation fk_extra]} {
			foreach {column value} $fk_extra {
				append where_extra " AND $fk_table.$column = '$value'"
			}
		}

		append sql_select $where_extra
	}
	
	:method relationsMultipleOrSimple {} {
		:upvar relation relation sql_select sql_select 

		if {[dict exists ${:attributes} relations $relation many_table]} {
			set sql_select "SELECT $select
			FROM $fk_table,$many_table,$table
			WHERE $many_table.$many_column = $table.$column
			AND $fk_table.$fk_column = $many_table.$many_fk_column
			AND $table.$column = :column"
		} else {
			set sql_select "SELECT $select 
			FROM $fk_table,$table
			WHERE 	 $fk_table.$fk_column = $table.$column
			AND $table.$column = :column"
		}
	}


	# This function searches by condition..
	#TODO fix relations so we can search multiple
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


	:public method computeWhere {where first {numericStmt 0} {table ""} } {
		# Compute where selection..  #in multiple functions
		#set first 0
		if {$table ==""} {
			set table [dict get ${:attributes} table]
		}
		set where_sql ""
		set pr_stmt ""
		set firstin 100

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
						append inval $what :$firstin 
						dict set pr_stmt $firstin $argin
						incr firstin 
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
	
	:public method computeRelations {toSelect table first} {
		# Computes relations when selecting multiple databases
		set first 0
		set from ""
		set pr_stmt ""
		set newSelect ""
		set where_sql ""
		if {$toSelect  == "*"} {
			set relSelect [dict keys [dict get ${:attributes} relations]]
			set colSelect [dict keys [dict get ${:attributes} sqlcolumns]]
			set toSelect [concat $colSelect $relSelect]

			#	set toSelect "${table}.*" 

		}

		foreach ts $toSelect {
			if {[dict exists ${:attributes} relations $ts]} {
				set many_table ""
				foreach {k v} [dict get ${:attributes} relations $ts] { set $k $v }	

				if {$many_table!=""} {
				#	lappend newSelect $ts
				#	append form ", ..."
				#
				#Whenever you want many-to-many ... just select the current ID!
	 		#TODO this should work for multi keys..
				if {0} {
					set pks [dict get ${:attributes} primarykey]
					if {[llength $pks] == 1} {

						puts "llength is 1 for $pks"
						lappend newSelect "$table.id as $ts"
					} else {	
						set c 0
						foreach pk $pks {
						#	append ok_pk  "($table.id as $ts"

							append pk_col_value  [expr {$c==0? "" : " || ' ' || "}] $pk
							incr c
						}
						lappend newsSelect "$pk_col_value as $ts"
					}
			} else {
						lappend newSelect "$table.id as $ts"
				}
					continue 
					#This will never run..
					lappend  newSelect " (SELECT array (SELECT DISTINCT ${fk_table}.${fk_value}
					FROM $fk_table,$many_table,$table
					WHERE $many_table.$many_column = $table.$column
					AND $fk_table.$fk_column = $many_table.$many_fk_column) as ok) as $ts"

				}
			if {[lsearch $from $fk_table ] == -1}	{
				#An extra verification to be sure we don't include the same table 2 times if it 
				#has relationships to itself 
				if {$fk_table != $table} {
					append from " , $fk_table"
				}
			}
				#TODO this is postgresql only? 
					#Concatenate multiple the columns in fk_value
					#
					#Mapping type 
					#Currently mapping ONE TO ONE and one-to-many/many-to-one but not at the same time..
					# one-to-many User has multiple telephone nr's (tables User(id), UserPhones(user_id, telephone)
					#TODO many-to-many User has hobbies (tables User (id), Hobbies (id,name), UserHobbies (user_id,hobby_id)
					#	tags {column id
		  			#		fk_table tags fk_column id  fk_value tag
		  			#		many_table goldbag_tags many_column goldbag_id many_fk_column tag_id  }
					#		column <-> many_column
					#		fk_column <-> many_fk_column
			if {[llength $fk_value] > 1} {
				#	set fk_col_value "concat("
				set fk_col_value ""
				set c 0
				foreach v $fk_value {
				#append fk_col_value  [expr {$first==0? "" : ","}]${fk_table}.${fk_value}
					append fk_col_value  [expr {$c==0? "" : " || ' ' || "}] ${fk_table}.${v}
					incr c
				}
				#	append fk_col_value ")"
				} else {
					#If a fk_function exists..
					if {[info exists fk_function]} {
						set fk_col_value [string map ":fk_value ${fk_table}.${fk_value}" $fk_function]
						 
					}  else {		set fk_col_value ${fk_table}.${fk_value} }

				}
				#		puts "fk_col_value $fk_col_value"
				lappend newSelect "$fk_col_value as $ts"	

				#	lappend newSelect "${fk_table}.${fk_value} as $ts"	
				set what [expr {$first==0? "" : " AND"}]
				append where_sql "$what ${table}.${column}=${fk_table}.${fk_column}"
				incr first
				
				#TODO select from current table and also from many_table like form fk_extra
				#In case you need to select an extra field from the foreign_key table
				set where_extra ""
				if {[dict exists ${:attributes} relations $ts fk_extra]} {
					foreach {column value} $fk_extra {
						append where_extra " AND $fk_table.$column = '$value'"
					}
				}
				append where_sql $where_extra



			} else {
				lappend newSelect "$table.$ts"
			}
		}
 	#	puts [dict create where_sql $where_sql toSelect $newSelect  first $first from $from]

	#	puts "Compute relations has tables $from"
		return [dict create where_sql $where_sql toSelect $newSelect  first $first from $from]
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
