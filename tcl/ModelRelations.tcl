nx::Class create ModelRelations {
	#${:attributes}  =  :attributes
#TODO REFACTOR !!!!!!1
# Relations selection.. 
# #TODO MULTI PK
	:public method relations {relation {id ""}} {
		if {![dict exists ${:attributes} relations $relation]}  {
			return ""
		}
		set table [:getTable]
		set select ""

		#Sets all the relation variables 
		foreach {k v} [dict get ${:attributes} relations $relation] { set $k $v }	
		foreach value $fk_value {
			append select  ${fk_table}.$value
		}

		set criteria [SQLCriteria new -table $fk_table]

		if  {$id == ""} {
			dict set pr_stmt column [my get $column]
		} else { dict set pr_stmt column $id }

		:relationsMultipleOrSimple
		:relationsExtraColumn

		my sqlstats $sql_select
		set values  [dbi_rows -db ${:db} -columns columns -bind $pr_stmt $sql_select ]
		dict set :attributes relations $relation value $values

		return $values
	}

	#This function allows you to specify standard select data for relations
	#using the fk_extra { column value } option in a model
	:method relationsExtraColumn {} {
		foreach refVar {relation fk_extra fk_table sql_select criteria pr_stmt} { :upvar $refVar $refVar }

		if {[dict exists ${:attributes} relations $relation fk_extra]} {
			foreach {column value} $fk_extra {
				$criteria add $column $value
				#If this doesn't work try using addRelation
			#	append where_extra " AND $fk_table.$column = '$value'"
			}
		}

		append sql_select [$criteria  getCriteriaSQL]
		set pr_stmt  [dict merge ${pr_stmt} [$criteria getPreparedStatements]]
	}

	:method relationsMultipleOrSimple {} {
		foreach refVar {fk_table fk_column many_table many_column many_fk_column column 
				  	table select relation sql_select} { :upvar $refVar $refVar }

		if {[dict exists ${:attributes} relations $relation many_table]} {
			set sql_select "SELECT ${select}
			FROM $fk_table,$many_table,${table}
			WHERE $many_table.$many_column = ${table}.$column
			AND $fk_table.$fk_column = $many_table.$many_fk_column
			AND ${table}.$column = :column"
		} else {
			set sql_select "SELECT ${select} 
			FROM $fk_table,${table}
			WHERE 	 $fk_table.$fk_column = ${table}.$column
			AND ${table}.$column = :column"
		}
	}
}
