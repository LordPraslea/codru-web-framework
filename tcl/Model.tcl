##########################################
# Database File 
##########################################
#
# Contains functions to connect to database
# select, inserts...
# and objects that will be inherited by other
# That model page controls everything
# using http://jqueryvalidation.org/ on client side (sending validation rules from server to client!)
# + the same function that generates them, will control if validation IS DONE on server side..
#

#MODEL 
nx::Class create Model {

	:property -accessor public attributes  ; #Attribute dict/list/array  name  value
	:property  -accessor public  alias   ;#Alias for query

	:property {newRecord 1} ;#Used when inserting/saving..
	:property {database ""}

	:variable -accessor public db 
	:variable scenario insert

	:variable sqlstats 

	:variable bhtml
	:variable table  ;#table name

	:variable loaddata 1

	:method init {} {
		#Get Default database 
		if {${:database} == ""} {
			if {[ns_cache_get lostmvc config.[getConfigName] config]} {
			#	puts "Config is $config"
				set :db [dict get $config database]	
			} else { set :db [dbi_ctl default]  }
		} else {
			set :db ${:database}
		}
		:genScenarios
	}

	:public method bhtml {{b ""}} {
		if {$b == ""} {
			return ${:bhtml}
		}
		set :bhtml $b

	}
	:public method existsbhtml {} {
		if {[info exists :bhtml]} {
			return 1
		}
		return 0;
	}
	
	:public method loaddata {{val ""}} {
		if {$val != ""} {
			set :loaddata $val
		}
		return ${:loaddata}
	}

	:public method existsValidation {name validation} {
		if {[dict exists ${:attributes} sqlcolumns $name validation $validation]} {
			return 1
		}
		return 0
	}

	:public method isNewRecord {} {
		return ${:newRecord}
	}

	:public method classKey {key} {
		set class [string tolower [dict get ${:attributes} table ]]
		#return  $class\[$key\]
		#return  "$class\($key\)"
		return  "${class}_${key}"
	}
	:public method getAttributes {} {
		return ${:attributes}
	}
	:public method setAlias {name newalias} {
		if {[dict exists ${:alias} $name ]} {
			dict set alias $name $newalias
		}
	}
	:public method getAlias {name} {
		if {[dict exists ${:alias} $name]} {
			return [mc [dict get ${:alias} $name]]
		} else { return $name }
	}
	:public method addError {name error} {
		dict lappend :attributes errors $name [list $error]
	}
	:public method getErrorsFor {name} {
		if {[dict exists ${:attributes} errors $name]} {
			return [dict get ${:attributes} errors $name]
		} else { return "" }

	}
	:public method getTable {} {
		return [dict get ${:attributes} table]
	}

	#SQL Stats command knowing what SQL was written for this page..
	:public method sqlstats {sql} {
		dict incr :sqlstats count
		dict lappend :sqlstats sql $sql
	}

	#Unset a variable (so it will not be saved)
	:public method unset {name} {
		if {[dict exists ${:attributes} sqlcolumns $name value]} {
			dict unset :attributes sqlcolumns $name value
		}
	}

	:public method exists {name} {
		# Verify if the name exists  otherwise if it's a relation or not
		return [expr {[dict exists ${:attributes} sqlcolumns $name] ? 1 : [dict exists ${:attributes} relations $name]}]
	}
	:public method setScenario {name} {
		set :scenario $name
	}
	:public method getScenario {} {
		return ${:scenario}
	}


	:public method genScenarios {} {
	#This function is ran to generate a scenarios variable that contains all scenario's
	#se we don't load all the columns anymore and know exactly which to use.
	#It easily works with multiple scenarios

		foreach key [dict keys [dict get ${:attributes} sqlcolumns]] {
			if {[dict exists ${:attributes} sqlcolumns $key unsafe]} {
				if {[dict exists ${:attributes} sqlcolumns $key unsafe on]} {
					set unsafe_scenarios [dict get ${:attributes} sqlcolumns $key unsafe on]
				} else { set unsafe_scenarios all }
				foreach unsafe_sc $unsafe_scenarios {
					dict set scenarios $unsafe_sc unsafe $key 1
				}
			#	puts "Scenario $unsafe_scenarios unsafe $key"
			}
			
			if {[dict exists ${:attributes} sqlcolumns $key validation]} {
				foreach {v extra} [dict get ${:attributes} sqlcolumns $key validation] {
					if {[dict exists ${:attributes} sqlcolumns $key validation $v on]}	{
						set validation_on [dict get ${:attributes} sqlcolumns $key validation $v on]
					} else { set validation_on all }
					#You can put the $v or validation but it's just safer/easier to specify that it's safe :)
					foreach val $validation_on {
						dict set scenarios $val safe  $key 1
					}
					#dict set scenarios $validation_on $v  $key 1

				#	puts "Scenario $validation_on $v $key ($v  extra: $extra)"
				}
			}
		}
		dict set :attributes scenarios $scenarios	
	}
	
	:public method getScenarioKeys {} {
		#Return all the keys that can be used in this scenario 
		return [dict get ${:attributes} scenarios]
	}

	#then just put those for that scenario!
	#futile to get them all.. just for "the fun of it"
	#exclude unsafe anyway
	#Gets all variables for defined scenario..
	:public method getQueryAttributes {{method POST}} {
		set returnattributes ""
		if {[ns_conn method] == $method} {
			set sc [my getScenario]
			if {[dict exists ${:attributes} scenarios all safe]} {
			  set all [dict get ${:attributes} scenarios all safe]
			} else { set all "" }
			if {[dict exists ${:attributes} scenarios $sc safe]} { 
				#Merge dupplicates..
				set all_attributes [dict merge  [dict get ${:attributes} scenarios $sc safe] $all]
			} else {
				set all_attributes $all
			}
			#Only get the "safe" ones from this scenario
			foreach {key n } $all_attributes {
				##dict set attributes sqlcolumns last_name validation exact 
				#Get all variables return the variables and also set the keys
			
				set value [string trim [ns_queryget  [my classKey $key]]]
					#Old remains from old version where we got every las one of the attributes..
				if {[dict exists ${:attributes} sqlcolumns $key unsafe]} {		
					#If this scenario is unsafe.. don't save it!
					set scenarios [dict get ${:attributes} sqlcolumns $key unsafe on]
					if {([my getScenario] in  $scenarios) || ($scenarios == "all") } {
					#	my set $key "" ;#Just set it to empty											   
						continue
					}
				}
				:set $key $value
				lappend returnattributes $key $value
			}
		}
		return $returnattributes
	}
	
	#maybe someone really wants to get them all..
	:public method getAllQueryAttributes {{method POST}} {
		set returnattributes ""
		#TODO control this outside..?
		if {[ns_conn method] == $method} {
			foreach key	[dict keys [dict get ${:attributes} sqlcolumns]] {
				##dict set attributes sqlcolumns last_name validation exact 
				#Get all variables return the variables and also set the keys

				set value [string trim [ns_queryget  [my classKey $key]]]

				if {[dict exists ${:attributes} sqlcolumns $key unsafe]} {		
					#If this scenario is unsafe.. don't save it!
					set scenarios [dict get ${:attributes} sqlcolumns $key unsafe on]
					if {([my getScenario] in  $scenarios) || ($scenarios == "all") } {
					#	my set $key "" ;#Just set it to empty											   
						continue
					}
				}
				my set $key $value
				lappend returnattributes $key $value
			}
		}
		return $returnattributes
	}

	:public method getErrors {} {
		# Return all the errors for all the attributes in the form
		set toreturn ""

		if {[dict exists ${:attributes} errors ]} {
			foreach {key values} [dict get ${:attributes} errors] {
				foreach val $values {
					lappend toreturn $val
				}
			}
		}
		return $toreturn

	}
	
	#Cache duration - dependency - time
	##At the moment we use naviserver function for caching.. maybe implement a psuedo class if the
	#naviserver functions don't exist
	:public method cache {args} { 
		ns_parseargs {{-key ""} {-location memory} -- time value } $args
		# Locations for cache:
		# 	File - In memory (naviserver) - fast Key Value Database - other
		# Unique Key: 
		# 	each cache has an unique key that can be set
		#   Controller-View combination
		# 	SQL command cache
		# TIME
		# 	to cache(in seconds)
		# Changes Trigger
		# 	When something triggers, change it

	}

	#Set the "field"
	#Also provides multiset (name value)
	:public method set {args} {
		if {[expr {[llength $args]%2}]} { error "Wrong nr args, should be: name value ?name value? ..." }
		foreach {name value} $args {
			#TODO comment the if if you want to set columns that are not defined in the model
			if {[dict exists ${:attributes} sqlcolumns $name]} {
			#puts "Setting $name to $value"
			#using ns_escapehtml instead of ns_quotehtml
				dict set :attributes sqlcolumns $name value [ns_escapehtml $value] 
			} elseif {[dict exists ${:attributes} relations $name]} {
				dict set :attributes relations $name value [ns_escapehtml $value]
			}
		}
	}

	#Increase object value
	#Reduce typing
	:public method incr {name {incr 1}} {
		if {[dict exists ${:attributes} sqlcolumns $name]} {
			set value [my get $name]
			incr value $incr
			dict set :attributes sqlcolumns $name value [ns_escapehtml $value] 
		} elseif {[dict exists ${:attributes} relations $name]} {
			set value [my get $name]
			incr value $incr
			dict set :attributes relations $name value [ns_escapehtml $value]
		}
	}
	#Get the "field"
	:public method get {name} {
		if {[dict exists ${:attributes} sqlcolumns $name value]} {
			return [dict get ${:attributes} sqlcolumns $name value]
		}  elseif {[dict exists ${:attributes} relations $name value]} {
			return [dict get ${:attributes} relations $name value]
		}

		#Returns empty if nothing found..
		#return "&nbsp;"
	}

	#TODO Relations between tables
	##TODO things like
	#belongs_to 	foreign_key fk_id other_table other_table_id  
	#has_one
	#has_many       this_id 	other_table	other_table_id
	#many_many 		
	#stat(istical)
	##TODO more complex relations.. to select for every other thing.. like "search" but more advanced..
	#TODO FORCE and cache..
	:public method relations {relation {id {}}} {
		if {![dict exists ${:attributes} relations $relation]}  { # puts "Relation doesn't exist $relation";
			return "" }
			#NEVER use the following, it will cache only one data.. never recalculating, it's better to 
		#	if {[dict exists ${:attributes} relations $relation value]} { return [dict get ${:attributes} relations $relation value] }
		set table [my getTable]
		foreach {k v} [dict get ${:attributes} relations $relation] { set $k $v }	
		foreach value $fk_value {
			append select  ${fk_table}.$value
		}

		#TODO select from current table and also from many_table like form fk_extra
		#In case you need to select an extra field from the foreign_key table
		set where_extra ""
		if {[dict exists ${:attributes} relations $relation fk_extra]} {
			foreach {column value} $fk_extra {
				append where_extra " AND $fk_table.$column = '$value'"
			}
		}

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
		append sql_select $where_extra
		#puts "SQL for relation is $sql_select"
		if  {$id == ""} {
			dict set pr_stmt column [my get $column]
		} else { dict set pr_stmt column $id }
		#	ns_puts "Ok relation $sql_select $pr_stmt .. $column should be [my get $column] and id is $id <br>"
		my sqlstats $sql_select
		set values  [dbi_rows -db ${:db} -columns columns -bind $pr_stmt $sql_select ]
		dict set attributes relations $relation value $values
		return $values
		if {0} {
			lappend  newSelect " (SELECT array (SELECT DISTINCT ${fk_table}.${fk_value}
			FROM $fk_table,$many_table,$table
			WHERE $many_table.$many_column = $table.$column
			AND $fk_table.$fk_column = $many_table.$many_fk_column) as ok) as $ts"
		}	
}


	:public method findByCond {{-numericStmt 0} {-relations 0} {-save 1} conditions } {
		# This function searches by condition..
		#TODO fix relations so we can search multiple
		#
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


	:public method findByPk {{-relations 0} -- id {save 1}} {
		#TODO handle and find if multiple primary keys..
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

	
	:public method validate {{onecolumn ""}} {
		#
		#	Model validation. We control if Errors == 0 then no errors occured
		#	Otherwise we have a list
		#	TODO simplification needed for unsafe values
		#
		set errors "0";
		if {$onecolumn != ""} {
			set columns $onecolumn	
		} else {
			#set columns [dict keys [dict get ${:attributes} sqlcolumns]] 
			#dict get ${:attributes} scenarios $this_scenario safe
			#
			# Look at scenario and get good columns
		if 	{[dict exists ${:attributes} scenarios all safe]} {
			set all [dict get ${:attributes} scenarios all safe]
		} else { set all "" }
			if {[dict exists ${:attributes} scenarios [my getScenario] safe]} {
				set columns [dict merge [dict get ${:attributes} scenarios [my getScenario] safe] $all]
			} else { set columns $all }
		#	puts "Ok for $columns"
		}
		#If validating all of them..use columns otherwise ev = empty value .. for when getting scenarios 
		foreach {column ev} $columns  {
			set columnerrors "";
			#TODO Errors set to 0 meaning there are no errors.. this was 1, maybe change to "" (empty string?)
			if {![dict exists ${:attributes} sqlcolumns $column validation]} { continue }
			foreach {valid extra} [dict get ${:attributes} sqlcolumns $column validation] {
			#if this isn't for the scenario.. just skip it alltogether
				if {[dict exists $extra on]} {
					set on [dict get $extra on]
			#		#If the scenario doesn't need validation.. just return
					if {[my getScenario] ni $on && $on != "all"} {  
					#	puts "Shouldn't verify if $column is valid"
						continue 
					}
				}
			#TODO verify if switchValid is empty..don't add text, if not empty go to next one(we already have something wrong..)
				set err [my switchValid $valid $extra $column]
				if {$err != 0} { lappend columnerrors $err	}
				#lappend columnerrors [my switchValid $valid $extra $column]
			}
			if {[join $columnerrors] != ""} {
				dict set :attributes errors $column $columnerrors
			}
		}
		if {[dict exists ${:attributes} errors]} {
			set errors [dict get ${:attributes} errors]
		}
		return  $errors
	}




	:public method switchValid {valid extra column} {
		#This function validates the attributes before saving in the database
		set column_name [my getAlias $column]
		#This isn't usually needed since value is always EMPTY
		if {![dict exists ${:attributes} sqlcolumns $column value]}  { return "$column has no value set"  }
	#puts "switchvalid for $column  $valid $extra"
		set value [dict get ${:attributes} sqlcolumns $column value]
	#	puts "validating $valid for $column extra $extra and current value $value"
		if {[dict exists $extra message]} {
			set message [dict get $extra message]
		}
		if {[dict exists $extra rule]} {
			set rule [dict get $extra  rule]
		}
	
		switch -- $valid  {
			required {if {$value == ""} { return [msgcat::mc "%s is required" $column_name] } }
			string { if {0} { return "$column_name must be a string" } }
			not { if {[string match $value $rule]} { return [msgcat::mc {%1$s must not be %2$s} $column_name $rule]   } }
			exact { if {![string match $value $rule]} { return  [msgcat::mc {%1$s must be exactly %2$s} $column_name $rule]   } }

			match  {
				#TODO this
				if {![regexp $rule $value]} { return [msgcat::mc "This doens't match what is required.."] }
			}
			email { 
				set regexp {^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$}
				if {![regexp $regexp $value]} { return [msgcat::mc "%s must contain a valid e-mail address." $column_name]  }
			}
			in {
				set match 0
				foreach val $rule {
					if {[string match -nocase ${val} [string trim $value]]} { incr match 1 ; break }	
				}
				if {!$match} {return [msgcat::mc {%1$s must be one of the following: %2$s} $column_name [join $rule "; " ] ] }
			}
			max-length { if {[string length $value] > $rule} { return [msgcat::mc {%1$s is too long (maximum %2$s characters)} $column_name $rule] } }
			min-length { if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be at least %2$s characters long} $column_name $rule] } }
			exact-length { if {[string length $value] < $rule} { return [msgcat::mc {%1$s must be exactly %2$d characters long} $column_name $rule] }  }
			between {
				foreach {min max} $rule { }
				if {[string length $value] > $max || [string length $value] < $min} {
					return [msgcat::mc {%1$s must be between %2$s and %3$s characters long} $column_name $min $max ]  
				}
			}
			integer { if {![string is integer $value]} { return [msgcat::mc "%s must be an integer" $column_name] }  }
			numerical { if {![string is double $value]} { return [msgcat::mc "%s must be a number" $column_name]
				} }
			min-num { if {$value < $rule } { return [msgcat::mc {%1$s must be bigger than %2$s} $column_name $rule] } }
			max-num { if {$value > $rule } { return [msgcat::mc {%1$s must be smaller than %2$s} $column_name $rule] } }
			between-num {
				foreach {min max} $rule { }
				if {$min > $value || $max < $value} {
					return [msgcat::mc {%1$s must  be between number between %2$s and %3$s} $column_name $min $max] 
				}
			}
			length { 
			#TODO remove this in the near future because we're using min-length exact-length ..etc
				foreach {k v} $rule {

					switch -- $k  {
						min { 
							if {[string length $value] < $v} { return [msgcat::mc {%1$s must be at least %2$d characters long} $column_name $v]} 
						}
						max {
							if {[string length $value] > $v} { return [msgcat::mc {%1$s is too long (maximum %2$d characters)} $column_name $v] 
							}
						}	
					}
				}
			}
			same-as { 
				if {![string match [my get $column] [my get $rule]]} {
					return [msgcat::mc {%1$s must be same as %2$s. These two fields don't seem too match}  $column_name $rule]
				}
			}
			one-of {  }
			unsafe { 
				#Removed from here because there was a PROBLEM with this implementation:
				#say we want to save manually, this WON'T allow us!
			}
			default {
				#Default means either it doesn't exist or it's a programmable function of this model
				#RULE may contain different things..
				#It can even select from the database.. view if a file exists.. Verify if today is a special date..
				if {[set r [my $valid $extra $column $value]] != 0} {
					return $r
				}
				if {0} {
					#This is how you implement it..
					:public method verifyFirstname {rule column value} {
						puts "Verifying custom FirstName $rule"
						set column_name [my getAlias $column]
						if {![string match -nocase andrei $value]} {
							return "$column MUST be Andrei!"	
						}
						return 0
					}
				}
			}

		}
		return 0
	}

	#This is how you implement the default from the previous function
	:public method unique {extra column value} {
		#Verify if the column is unique
		if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set column_name [my getAlias $column]
		if {[my findByCond -save 0 [list $column $value] ]} {
			return [msgcat::mc 	{%1$s must be unique. There already exists someone who uses %2$s}	 $column_name $value] 
		
		}
		return 0
	}

	:public method captcha {extra column value} {
		if {![string match -nocase $value [ns_session get humanTest]]} {
			return [msgcat::mc 	{The code you've entered is incorrect, try again.}] 
		}
		:unset captcha
		return 0
	}

	#####################
	#	RBAC Roles
	#####################
	#Load Roles From DATABASE	
	:public method loadRoles {{userid ""}} {
		if {$userid ==""} { set userid [ns_session get userid] }
		set sql_select "
		SELECT ri.name, ri.type, ri.description, ri.bizrule, ri.data
		FROM role_assignment ra, role_item ri
		WHERE ra.item_id=ri.id 
		AND user_id=:user_id"
		dict set pr_stmt user_id $userid 

		set values  [dbi_rows -db [:db get] -columns columns -bind $pr_stmt $sql_select ]
	}

	#################################	
	# Tags management, can be used everywhere!
	#################################	
	:public method addTags {{-interTbl } {-tagsTbl tags} {-interId  } --  tags} {
		# Adds tags to the table specified
	#	set tags [my get tags]
		set this_id [:get id]
		set db [:db get]
		#set old tags.. if any..?
		#update them?
		set ltags [split $tags ","]
		#Find if tags exist in tags column
	#	puts "Tags gathered $ltags"
		set first 0
		set where_sql ""
		foreach {tag} $ltags {
			#Only do it if the key exists,
			#TODO remove this or figure this out for multi joined sql's
			set what [expr {$first==0? "" : "OR"}]
			dict set pr_stmt $first $tag
			append where_sql "$what tag = :$first "
			incr first
		}
			
		#search only if where_sql is something.. otherwise go further:) 
		#This means that no tags where selected
		if {$where_sql != ""} {
			set sql_select "SELECT tag,id FROM $tagsTbl WHERE $where_sql"
			set values  [dbi_rows -db ${:db} -columns columns -bind $pr_stmt $sql_select ]
		#	puts "Values $values"
		}
		set pr_stmt ""
	#	set values [my search -where  ]	
		#We have a list with existent tags..
		#For each exitent tag view if it's already linked to the esm
		#otherwise.. add it
		set ids ""
		set existingids ""
		set existingtags ""

		#TODO these could be put into 1 big insert and 2 big select's..
		foreach tag $ltags {
			#if tag is not in values.. then it means it's a fresh tag for our tags list
			#we ADD it!
		#	puts "Ohoooo ok $tag"
		#	#$tag ni $values  => is case sensitive:( 
			if {[lsearch -nocase  $values $tag] == -1} {
				unset pr_stmt
				dict set pr_stmt tag $tag
				set sql "INSERT INTO $tagsTbl (tag) VALUES (:tag) RETURNING id"
				set id  [dbi_0or1row -db ${:db} -array mytag -bind $pr_stmt $sql] 
			#	puts "Added tag $tag with id $mytag(id)"
				lappend ids $mytag(id)
			} else {
				#This tag exists in values, verifying if it's linked..
				##Get the right position
				set id [lindex $values [lsearch -nocase $values $tag]+1]
				dict set pr_stmt tag_id  $id		
				dict set pr_stmt $interId $this_id
				set sql_select "SELECT * FROM $interTbl WHERE tag_id = :tag_id AND $interId = :$interId "
			#	puts "\nSQL Select $sql_select with $pr_stmt\n"
				set linkedid  [dbi_0or1row -db ${:db}  -bind $pr_stmt $sql_select ]
				if {$linkedid} {			
					lappend existingids $id
					lappend existingtags $tag $id
				}
				lappend ids $id

			#	puts "Selecting $tag with $id .. is this linked? $linkedid "
			}

		}
		
		#TODO 1 big insert..
		foreach id $ids {
			#verify if this id isn't in existingids, if it isn't add it..
			if {$id ni $existingtags} {
				set pr_stmt ""
				dict set pr_stmt $interId $this_id
				dict set pr_stmt tag_id $id

			#	puts "Combining (esm_id,tag_id) ($esm_id,$id)"
				set sql "INSERT INTO $interTbl ($interId,tag_id) VALUES (:$interId,:tag_id)"
				set id  [dbi_dml -db ${:db} -bind $pr_stmt $sql] 
			}
		}
		return true
	}

	#TODO this will need to be rewritten to fit relations with model
	:public method getTags {{-interTbl } {-tagsTbl tags} {-interId  } } {
		#set sql_select "SELECT tag FROM tags t, esm_tags et WHERE "
		dict set pr_stmt $interId [my get id]
		set sql_select "SELECT tag FROM $tagsTbl t JOIN $interTbl et  ON t.id=et.tag_id WHERE et.$interId=:$interId "
		set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt $sql_select ]
		#set tags? or just return them..?
	#	puts "$values and [split $values ,] and [join $values ,]"
		set values [join $values ","]
		my set tags  $values 
		return $values
	}

	:public method removeTags {{-interTbl } {-tagsTbl tags} {-interId  } -- oldTags newTags } {
		#compare oldTags to newTags (find the unique)
		#remove those that are not in that list
		set first 0
		set oldTags [split $oldTags ,]
		set newTags [split $newTags ,]
	#	puts "OldTags $oldTags and newtags $newTags"
		set deleteTags ""
		foreach tag $oldTags {
			#Fixed ni (not in list) case sensitive  
			#if {$tag ni $newTags}   
			if {[lsearch -nocase  $newTags $tag] == -1} {
				lappend deleteTags $tag
			}	
		}	
		#Only delete if there are tags removed..
		if {$deleteTags != ""} {
			set idTags [my search -table $tagsTbl  -where [list "-cond IN tag [list $deleteTags]"] id]
			if {$idTags ==""} { return "Empty" }
			# puts "Nothing to delete.. because deleteTags $deleteTags couldn't find anything"; 
		#	puts "Found and will delete idTags [dict get $idTags values]"
			lappend selection [list  -cond IN tag_id [dict get $idTags values]]
			lappend selection [list $interId [my get id]]
			my delete -table $interTbl $selection
		} 
	}

	:public method updateTags {{-interTbl } {-tagsTbl tags} {-interId  } -- oldTags newTags } {
		#Update Tags (either by adding new ones or removing)
		#IF you've overwritten addTags and removeTags.. then these can be simple ones
	#	my addTags  -interTbl $interTbl -tagsTbl $tagsTbl -interId $interId $newTags
	#	my removeTags -interTbl $interTbl -tagsTbl $tagsTbl -interId $interId  $oldTags $newTags
		my addTags $newTags
		my removeTags $oldTags $newTags
	}

	#Selecting the TAG data from the database
	# firstTable is the original table for which we have firstTable_tags linkage with tags
	:public method getTagCloud {{-interTbl } {-tagsTbl tags}  {-interId  } {-firstTable }
							 {-firstColumnName ""} {-extraOptions ""} --  {firstId 0 } {minShow 1} } {
		set sql_select "SELECT $tagsTbl.id,$tagsTbl.tag, count($tagsTbl.id) as Count
		FROM $firstTable,$tagsTbl,$interTbl
		WHERE $firstTable.id   =  $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id
		"
		if {$firstColumnName != ""} {
			append sql_select "	AND $firstTable.$firstColumnName=:firstid"

			dict set pr_stmt firstid $firstId
		}
		append sql_select " GROUP BY $tagsTbl.tag,$tagsTbl.id
		HAVING count($tagsTbl.id)>=:minshow
		ORDER BY $tagsTbl.tag ASC"

		dict set pr_stmt minshow $minShow
			set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt {*}$extraOptions $sql_select ]
			return [dict create columns $columns values $values ]
		
	}

	#	gets the tag totals for a specific userid 
	#	and a count value for some kind of sum..
	:public method getTagTotals {{-interTbl } {-tagsTbl tags}  {-interId  } {-firstTable } {-firstColumnName ""} {-dateColumn }
							  {-valueColumn} {-grid 0}  {-extraOptions ""}	--  {firstId} {minShow 1} {begin_date ""} {end_date ""} } { 

		#This selects distinct values!
		set sql_size "
		SELECT  count(DISTINCT $tagsTbl.id) as size
		FROM $firstTable,$interTbl,$tagsTbl
		WHERE $firstTable.id   = $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id "

	set sql_select	"SELECT $tagsTbl.id,$tagsTbl.tag,count($tagsTbl.id) as Count,sum($firstTable.$valueColumn) as Total
		FROM $firstTable,$tagsTbl,$interTbl
		WHERE $firstTable.id   = $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id 	"
		if {$firstColumnName != ""} {
			append sql_select "	AND $firstTable.$firstColumnName=:firstid "
			append sql_size "	AND $firstTable.$firstColumnName=:firstid "

			dict set pr_stmt firstid $firstId
		}

		if {$begin_date != "" && $end_date != "" } {
			append sql_size " AND $firstTable.$dateColumn BETWEEN :begin_date AND :end_date "
			append sql_select " AND $firstTable.$dateColumn BETWEEN :begin_date AND :end_date "

			dict set pr_stmt begin_date $begin_date
			dict set pr_stmt end_date $end_date
		}
		append sql_select "	GROUP BY $tagsTbl.tag,$tagsTbl.id
		HAVING sum($firstTable.$valueColumn)>= :minshow"
		dict set pr_stmt minshow $minShow

		if {!$grid} {
			set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt {*}$extraOptions $sql_select ]
			return [dict create columns $columns values $values ]
		} else {
			return [dict create sql_select  $sql_select pr_stmt $pr_stmt sql_size $sql_size]
		}

	}

}


#TODO schema selection for different databases..
if {0} {
	mysql: SHOW TABLES
	postgresql: SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

	mysql: SHOW DATABASES
	postgresql: SELECT datname FROM pg_database;

	mysql: SHOW COLUMNS
	postgresql: SELECT column_name FROM information_schema.columns WHERE table_name ='table';

	mysql: DESCRIBE TABLE
	postgresql: SELECT column_name FROM information_schema.columns WHERE table_name ='table';

	Information 
SELECT column_name,data_type,is_nullable,column_default FROM information_schema.columns WHERE table_name='authors';
#SELECT * FROM information_schema.columns WHERE table_name='employees';
}
