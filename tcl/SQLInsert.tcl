#################################	
# SQL Insert 
#################################	

nx::Class create SQLInsert -mixin [list SQLCommands]  {

	# Insert a new record (multi insert possibile)
	#columns that you need in a FORM for processing but don't want to save should have
	# 	column {	save false  } in the model
	#
	#TODO figure out when you have multiple PK's.. when updating
	#
	
	:public method insert {args} {
		set table [dict get ${:attributes} table]
		set :pr_stmt [dict create]	
		set :columnCount 0

		if {[llength $args] == 0} {
			:insertModelColumns
		} else {
			:insertMultipleRows $args
		}

		set :sql "INSERT INTO $table ${:columns} VALUES ${:insert} "
		puts "SQL is ${:sql}"

		#If 1 or multiple primary keys, return.. otherwise don't return anything..
		if {[dict exists ${:attributes} primarykey]} {
			:insertPrimaryKeyReturning

		} else {
			#Inserting values with no primary key..
			set return  [dbi_dml -db ${:db} -bind ${:pr_stmt} ${:sql}] ;
		}

		set :newRecord 0
		set :scenario update ;
		return $return ;
	}

	:method insertModelColumns {} {
		foreach key [:getColumnsKeys]  {
		#	Insert only keys that have a value and may be saved
			if {[dict exists ${:attributes} sqlcolumns $key value]} {
				if {[dict exists ${:attributes} sqlcolumns $key save]} {
					if {![dict get ${:attributes} sqlcolumns $key save]}	 {  continue }
				}
				set separator [:getCondition ", "]
				append columns [format "%s%s" $separator   $key  ]

				set statement [:genStatement -type numeric $key [:get $key]]
				append insert [format "%s%s" $separator $statement]
			} 
		}
		set :columns "($columns)"
		set :insert "($insert)"

	}

	:method insertMultipleRows {args} {
	#	ns_parseargs {columns values}	$args
		foreach {columns rows} $args { }
		#Data is sanitized, later maybe add prepared statements?
		foreach currentRow $rows {
			set currentRow [ns_escapehtml $currentRow]
			append :insert [:getSeparator ", "]  ('[join $currentRow ',']')
		}
		set :columns "($columns)"
	}

	:method insertPrimaryKeyReturning {} {
			append sql [:insertPrimaryKeyReturningPostgreSQL] 
			set returnid [dbi_0or1row -db ${:db} -array mydata -bind ${:pr_stmt} ${:sql}] 
			if {$returnid == 0} { return false }
			foreach id	[dict get ${:attributes} primarykey] {
				my set $id $mydata($id)
			}
	}

	#Move these to a different mixin class..?
	:method insertPrimaryKeyReturningPostgreSQL {} {
		return " RETURNING [join [dict get ${:attributes} primarykey] ,]"		
	}

	:method insertPrimaryKeyReturningSQLite {} {
		return  " ; SELECT last_insert_rowid() FROM $table LIMIT 1"
	}


}

