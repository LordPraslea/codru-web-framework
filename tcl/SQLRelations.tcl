#################################	
#  SQL Relations (between tables)
#################################	

#	belongs_to 	foreign_key fk_id other_table other_table_id  
#	has_one		one-to-one
#	has_many       this_id 	other_table	other_table_id 
#	many_many 		
#stat(istical)

nx::Class create SQLRelations {

	:property -accessor public table
	:property model:object,type=Model
	:property criteria:object,type=SQLCriteria 
	:property select


	:property {statementCount 0}

	:method init {} {
		if {[info exists :select]} {
			:computeRelations ${:select}
		}
		 if {![info exists :table]} {
		 	set :table [${:model} getTable ]
		 }
	}

	:public method getToSelect {} {
		return ${:toSelect}
	}

	:public method getFrom {} {
		return ${:from}
	}

	:public method getCriteria {} {
		return ${:criteria}
	}


	# Computes relations when selecting multiple databases
	:public method computeRelations {toSelect } {
		set from ""
		set newSelect ""
		if {${:criteria} ==""} {
			set :criteria [SQLCriteria new -table ${:table}]
		}

		if {$toSelect  == "*"} {
			set relSelect [${:model} getRelationsKeys]
			set colSelect [${:model} getColumnsKeys]
			set toSelect [concat $colSelect $relSelect]
		}

		foreach ts $toSelect {
			if {[${:model} existsRelation $ts]} {
				:generateRelationDataFor $ts
			} elseif {[${:model} existsColumn $ts]} {
				lappend newSelect "${:table}.$ts"
			} else {
			#Special not mentioned relation we add it as it is

			}
		}
		set :from $from
		set :toSelect $newSelect

		#return [dict create where_sql $where_sql toSelect $newSelect  first $first from $from]
	}

	if {0} {
		tags {column id
		fk_table tags
		fk_column id 
		fk_value tag
		many_table blog_tags 
		many_column post_id
		many_fk_column tag_id 
		}
		date 	{column id fk_table lucrare_date fk_column lucrare_id 
		 fk_value data fk_function "substr(:fk_value,0,1000)" fk_extra { type  lucrare}  	}
	}
	#relations
	# name { 
	#		fk_table "foreign key table name"
	#		fk_column "foreign key column to select and work with"
	#		fk_value "OPTIONAL what value to show eventually"
	#		fk_function "OPTIONAL a function you want to run "
		#		fk_extra "OPTIONAL {column value } will produce column = value "
		# Many to many relationships tags (id,name) -> blog_tags (tag_id,post_id) <- posts (id)
		#		many_table "the table "
		#		many_column "the colum associated with this model's ID"
		#		many_fk_column "the column associated with the foreign key ID"
		#		
		#		column <-> many_column
		#		fk_column <-> many_fk_column
	# }
	#
	:public method generateRelationDataFor {ts} {
		upvar newSelect newSelect from from
		set many_table ""
		foreach {k v} [${:model} getRelations $ts] { set $k $v }	

		if {$many_table!=""} {
			:computeMultiTables $ts

		}
		#An extra verification to be sure we don't include the same table 2 times if it #has relationships to itself 
		if {[lsearch $from $fk_table ] == -1}	{
			if {$fk_table != ${:table}} {
				append from " , $fk_table"
			}
		}
		:computeForeignKeyValue $ts

		${:criteria} addRelation -table ${:table} -fk_table $fk_table  $column $fk_column 

		#TODO select from current table and also from many_table like form fk_extra
		#In case you need to select an extra field from the foreign_key table
		if {[dict exists [${:model} getAttributes] relations $ts fk_extra]} {
			foreach {column value} $fk_extra {
				${:criteria} addRelation -table $fk_table $column '$value' 
			}
		}
	}

	:method computeMultiTables {ts} {
	#	lappend newSelect $ts
	#	append form ", ..."
	#
	#Whenever you want many-to-many ... just select the current ID!
	#TODO this should work for multi keys..
		if {0} {
			set pks [dict get [${:model} getAttributes] primarykey]
			if {[llength $pks] == 1} {

				puts "llength is 1 for $pks"
				lappend newSelect "${:table}.id as $ts"
			} else {	
				set c 0
				foreach pk $pks {
					#	append ok_pk  "(${:table}.id as $ts"

					append pk_col_value  [expr {$c==0? "" : " || ' ' || "}] $pk
					incr c
				}
				lappend newsSelect "$pk_col_value as $ts"
			}
		} else {
			lappend newSelect "${:table}.id as $ts"
		}
		#This returns 2 functions higher (from the days there was 1 unrefactored function)
		return -level 2	-code continue 
		#This will never run..
		lappend  newSelect " (SELECT array (SELECT DISTINCT ${fk_table}.${fk_value}
		FROM $fk_table,$many_table,${:table}
		WHERE $many_table.$many_column = ${:table}.$column
		AND $fk_table.$fk_column = $many_table.$many_fk_column) as ok) as $ts"
	}	

	#Computes the foreign key value in fk_value
	#(if you want something else than fk_column)
	:method computeForeignKeyValue {ts} {
		foreach refVar {fk_value fk_table fk_function newSelect} { :upvar $refVar $refVar }

		#Concatenate multiple values
		if {[llength $fk_value] > 1} {
			set fk_col_value ""
			set c 0
			foreach v $fk_value {
				append fk_col_value  [expr {$c==0? "" : " || ' ' || "}] ${fk_table}.${v}
				incr c
			}
		} else {
		#If a fk_function exists, currently works with 1 fk_value
			if {[info exists fk_function]} {
				set fk_col_value [string map ":fk_value ${fk_table}.${fk_value}" $fk_function]
			}  else {		set fk_col_value ${fk_table}.${fk_value} }
		}
		lappend newSelect "$fk_col_value as $ts"	
	}

		
}
