##########################################
# Model Database File 
##########################################

nx::Class create Model -mixin [list  ModelRelations ] \
	-superclasses [list  SQLSelect SQLInsert SQLUpdate SQLRecycle ModelValidation NodJsModelValidation RbacModel TagModelManagement]  {

	:property -accessor public attributes  ; #Attribute dict/list/array  name  value
	:property  -accessor public  alias   ;#Alias for query

	:property {newRecord 1} ;#Used when inserting/saving..
	:property {database ""}
	:property {debug 0}

	:property {outsideADP 0}

	:variable -accessor public db 
	:variable -accessor public schema public
	:variable scenario insert

	:variable sqlstats 
	:variable relationSQL ""

	:variable bhtml
	:variable table  ;#table name

	:variable loaddata 1

	:method init {} {
		#Get Default database 
		#
 		if {!${:outsideADP}} {
			ns_cache_get lostmvc config.[getConfigName] config
		}

		
		if {${:database} == ""} {
			if {[info exists config]} {
			#	puts "Config is $config"
				set :db [dict get $config database]	
			} else { set :db [dbi_ctl default]  }
		} else {
			set :db ${:database}
		}
		if {[info exists config]} {
			if {[dict exists $config schema ]} {
				set :schema [dict get $config schema] 
			}

			if {[dict exists $config mode ]} {
					
				if {[set mode [dict get $config mode]] == "debug"} {
					set :debug 1
				}
			}
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
			dict set alias $name $newalias
	}
	:public method getAlias {name} {
		if {[dict exists ${:alias} $name]} {
			return [mc [dict get ${:alias} $name]]
		} else { return $name }
	}
	:public method getTable {} {
		return [dict get ${:attributes} table]
	}



	#SQL Stats command knowing what SQL was written for this page..
	:public method sqlstats {sql} {
		dict incr :sqlstats count
		dict lappend :sqlstats sql $sql
	}

	
	:public method getColumnsKeys {} {
		return [dict keys [dict get ${:attributes} sqlcolumns]] 
	}

	:public method getRelationsKeys {} {
		return [dict keys [dict get ${:attributes} relations]] 
	}

	:public method getRelations {relation} {
		return [dict get ${:attributes} relations $relation]	
	}


	:method setRelation { relation relationdata } {
		dict set :attributes relations relation $relationdata
	}

	:public method setRelationSQL {relation sql} {
		dict set :relationSQL $relation $sql
	}
	
	:public method getRelationSQL {relation} {
		if {[dict exists ${:relationSQL} $relation]} {
			return [dict get ${:relationSQL} $relation]
		}
		return ""
	}
	
	

	
	##################Errors
	:public method addError {name error} {
		dict lappend :attributes errors $name [list $error]
	}
	:public method getErrorsFor {name} {
		if {[dict exists ${:attributes} errors $name]} {
			return [dict get ${:attributes} errors $name]
		} else { return "" }

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


	#This function is ran to generate a scenarios variable that contains all scenario's
	#se we don't load all the columns anymore and know exactly which to use.
	#It easily works with multiple scenarios
	:public method genScenarios {} {
		foreach key  [:getColumnsKeys]  {
			if {[dict exists ${:attributes} sqlcolumns $key unsafe]} {
				if {[dict exists ${:attributes} sqlcolumns $key unsafe on]} {
					set unsafe_scenarios [dict get ${:attributes} sqlcolumns $key unsafe on]
				} else { set unsafe_scenarios all }
				foreach unsafe_sc $unsafe_scenarios {
					dict set scenarios $unsafe_sc unsafe $key 1
				}
			}
			
			if {[dict exists ${:attributes} sqlcolumns $key validation]} {
				:genValidationScenarios
			}
		}
		dict set :attributes scenarios $scenarios	
	}
	
	:method genValidationScenarios {} {
		upvar scenarios scenarios key key
		foreach {v extra} [dict get ${:attributes} sqlcolumns $key validation] {
			if {[dict exists ${:attributes} sqlcolumns $key validation $v on]}	{
				set validation_on [dict get ${:attributes} sqlcolumns $key validation $v on]
			} else { set validation_on all }
			#You can put the $v or validation but it's just safer/easier to specify that it's safe :)
			foreach val $validation_on {
				dict set scenarios $val safe  $key 1
			}
			#dict set scenarios $validation_on $v  $key 1
		}
	}
	
	:public method getScenarioKeys {} {
		#Return all the keys that can be used in this scenario 
		return [dict get ${:attributes} scenarios]
	}
	:public method setScenario {name} {
		set :scenario $name
	}
	:public method getScenario {} {
		return ${:scenario}
	}


	#then just put those for that scenario!
	#futile to get them all.. just for "the fun of it"
	#exclude unsafe anyway
	#Gets all variables for defined scenario..&
	#form variable is a special case when we use the spooler (and transfer multiple files..)
	:public method getQueryAttributes {{method POST} {form ""}} {
		set returnattributes ""
		if {[ns_getcontentmethod  $method]} {
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
				if {$form == "" && [ns_conn contentfile] == ""} {
					set value [string trim [ns_queryget  [my classKey $key]]]
				} else {
					set value [string trim [ns_set iget $form [my classKey $key]]]
				}
				#querygetall for checkboxes..	
				if {[dict exists ${:attributes} sqlcolumns $key checkbox]} {	

					if {$form == "" && [ns_conn contentfile] == ""} {
						set value [string trim [ns_querygetall  [my classKey $key]]]
					} else {
						set value [string trim [ns_getallform $form  [my classKey $key]]]
					}
				}
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
	:public method set {{-change 1} args} {
		if {[expr {[llength $args]%2}]} { error "Wrong nr args, should be: name value ?name value? ..." }
		foreach {name value} $args {
			#TODO comment the if if you want to set columns that are not defined in the model
			if {[dict exists ${:attributes} sqlcolumns $name]} {
			#using ns_escapehtml instead of ns_quotehtml
				dict set :attributes sqlcolumns $name value [ns_escapehtml $value] 
				if {$change} {	:changedValue $name }
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
			:changedValue $name
		} elseif {[dict exists ${:attributes} relations $name]} {
			set value [my get $name]
			incr value $incr
			dict set :attributes relations $name value [ns_escapehtml $value]
		}
	}
	
	#We need a list of changed values (incr/set)
	#save will only update those values (not the full thing)
	#This list will be reset when inserting/updating
	:public method changedValue {name} {
		dict lappend :attributes changedValues $name
		dict set :attributes changedValues [lsort -unique [dict get ${:attributes} changedValues ]]
	}
	
	#Only keep unique fields 
	:public method getFinalChangedValues {args} {
		set changed ""
		if {[dict exists ${:attributes} changedValues]} {
			set changed [lsort -unique [dict get ${:attributes} changedValues ]]
			dict set :attributes changedValues $changed
		}

		return $changed
	}
	
	
	#Get the "field"
	:public method get {name} {
		if {[dict exists ${:attributes} sqlcolumns $name value]} {
			return [dict get ${:attributes} sqlcolumns $name value]
		}  elseif {[dict exists ${:attributes} relations $name value]} {
			return [dict get ${:attributes} relations $name value]
		}
	}

	#Unset a variable (so it will not be saved)
	:public method unset {name} {
		if {[dict exists ${:attributes} sqlcolumns $name value]} {
			dict unset :attributes sqlcolumns $name value
		}
	}

	:public method exists {name} {
		# Verify if the name exists  otherwise if it's a relation or not
		return [expr {[:existsColumn $name] ? 1 : [:existsRelation $name]}]
	}

	:public method existsRelation {name} {
		return	[dict exists ${:attributes} relations $name]
	}

	:public method existsColumn {name} {
		return	[dict exists ${:attributes} sqlcolumns  $name]
	}

	
	# Validate the model, if everything is OK, it usually returns 1.. otherwise the list of errors:)
	# If 1 and newRecord 1 it inserts, if 1 and newRecord 0 it updates
	#[llength [my validate]]>1p
	# 

	:public method save {} {

		if {[my validate] !=0} {
			return 0
		} 

		#TODO beforeSave
		# TODO if insert/update returns 0, generate an error
		if {${:newRecord}} {
			return [:insert]
		} else {
			return [:update]
		}
		#TODO afterSave
		return 1
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
