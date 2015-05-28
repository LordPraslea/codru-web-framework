##########################################
# Controller Generation
##########################################

nx::Class create RoleitemchildController -superclass Controller {
	#variable layout

	:method init {} {
		#set attributes { %s }  
		#next $attributes $alias
		set :layout rbaclayout
		#my	setLayout layout
	}

	:public method accessRules {} {
		#TODO this here but this could also be found in the DATABASE tables!
		# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
		# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
		# actions  
		return [dict create views { 
			view  { allow { users @ } roles {superadmin rbac}}	
			index { allow { users @ } roles {superadmin rbac}}	
			update { allow { users @ } roles {superadmin rbac}}
			create { allow { users @ } roles {superadmin rbac}}
			delete { allow { users @ } roles {superadmin rbac}}
			admin { allow { users @ } roles {superadmin rbac}}
		}   ]
	}

	:public method filters {} {
	
		return ""
	}

	:public method currentController {}	{
		return [string tolower Roleitemchild];	
	}
	
	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [RoleItemChild new]
	}

	#:public method could have arguments as GET/POST 
	:public method actionView {} {
		foreach {key} {child_id parent_id} { set $key [ns_escapehtml [ns_get $key ]]  }

		if {[set model [my loadModel $parent_id $child_id]] ==0} { return }
		my render view model $model 
	}
	
	#TODO if PK same when creating new, view if not unique constraing..
	:public method actionCreate {} {
		set model [RoleItemChild new]
		#set bhtml [bhtml new]

		#For when you want ajax validation..
		#$model nodjsRules $bhtml

		#If POST...
		if {[ns_conn  method] == "POST"} {
		#	puts "Yeah, creating a new thingie here!"
			set queryattributes [$model getQueryAttributes POST ]
			#set errors [$model validate]
			#puts "errors are $errors"
			if {[$model save]} {
			#Redirect stops all other things from going on..
			#TODO PARENT ID REDIRECT!
			#	my redirect view id [$model get id] 
				my redirect -controller rbac index
				return 1
			}

		}
		#using ns_adp_parse AND ns_adp_include
		my render create model $model

	}

	#ruff
	#or arguments id? to be included for actionUpdate	
	#TODO handle errors if parent/child id already exist
	:public method actionUpdate {} {
		foreach {key} {child_id parent_id} { set $key [ns_escapehtml [ns_get $key ]]  }
		if {[set model [my loadModel $parent_id $child_id]] ==0} { return }
		if {[ns_conn  method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
			set updateCriteria [SQLCriteria new -model $model]

			$updateCriteria addUpdateCriteria  parent_id [$model get parent_id]
			$updateCriteria addUpdateCriteria   child_id [$model get child_id]
			set whereCriteria [SQLCriteria new -model $model]
			$whereCriteria add -includeTable 0 child_id	 $child_id
			$whereCriteria add -includeTable 0 parent_id $parent_id

			if {[$model updateMultipleRows $updateCriteria  $whereCriteria]} {
				my redirect view parent_id [$model get parent_id] child_id  [$model get child_id]
				return 1
			}
		}
	#	puts "Generating the update thingie.."
		#using ns_adp_parse AND ns_adp_include
		my render update model $model

	} 


	:public method actionAdmin {} {
		set model [RoleItemChild new]
		#TODO unset any default values in model

		if {[ns_conn :public method] == "POST"} {
			$model getQueryAttributes POST
		}
		my render admin model $model 
	}

	:public method loadModel {parent_id child_id} {
		set model [RoleItemChild new]
		$model setScenario "search"
		if {![string is double $parent_id] || ![string is double $child_id] } {

			set result [$model searchByName $parent_id $child_id]
		} else {
			set result [$model findByPk -relations 1 [list $parent_id $child_id] ] 
		}

	#	$model set id $id 
	#	if {[set validation [$model validate id]] != 0} { 	my notFound  [msgcat::mc "Not validating, sorry! %s" $validation]; return 0 }


		if {$result == 0} {
			my notFound <br>[msgcat::mc "Tried to search for parent_id %s and child_id %s but just couldn't find it!" $parent_id $child_id]
			return 0
		} else {  	return $model; }
	} 


	
}



