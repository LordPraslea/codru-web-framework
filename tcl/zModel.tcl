##########################################
# Model Database File 
##########################################

# Classes to use

#Model -superclass DatabaseModel

#DatabaseModel

#SQLGenerator
#	SQLGeneratorPostgreSQL
#	SQLGeneratorSQLite

#ModelValidation
#	NodJsModelValidation

#TagModelManagement



nx::Class create Model -superclass [list SQLGenerator ModelValidation NodJsModelValidation] {

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

	#This function is ran to generate a scenarios variable that contains all scenario's
	#se we don't load all the columns anymore and know exactly which to use.
	#It easily works with multiple scenarios
	:public method genScenarios {} {
		foreach key [dict keys [dict get ${:attributes} sqlcolumns]] {
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
