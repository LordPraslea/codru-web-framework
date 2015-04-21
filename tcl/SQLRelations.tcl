#################################	
#  SQL Relations (between tables)
#################################	

nx::Class create SQLRelations {
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

}
