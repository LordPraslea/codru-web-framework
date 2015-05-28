##########################################
# Controller Generation
##########################################

nx::Class create RoleassignmentController -superclass Controller {
#	variable layout

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
		return [string tolower Roleassignment];	
	}
	
	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [RoleAssignment new]
	}

	#method could have arguments as GET/POST 
	:public method actionView {} {
		foreach {key} {item_id user_id} { set $key [ns_escapehtml [ns_get $key ]]  }

		if {[set model [my loadModel $item_id $user_id]] ==0} { return }
		my render view model $model 
	}

	#TODO if PK same when creating new, view if not unique constraing..
	:public method actionCreate {} {
		set model [RoleAssignment new]
		#set bhtml [bhtml new]

		#For when you want ajax validation..
		#$model nodjsRules $bhtml

		#If POST...
		if {[ns_conn method] == "POST"} {
		#	puts "Yeah, creating a new thingie here!"
			set queryattributes [$model getQueryAttributes POST ]
			#set errors [$model validate]
			#puts "errors are $errors"
			if {[$model save]} {
			#Redirect stops all other things from going on..
			#TODO correct render.. put a primary key field..?
			#my redirect view id [$model get id] 
			my redirect index
				return 1
			}

		}
		#using ns_adp_parse AND ns_adp_include
		my render create model $model

	}

	:public method actionUpdate {} {
		foreach {key} {item_id user_id} { set $key [ns_escapehtml [ns_get $key ]]  }
		if {[set model [my loadModel $item_id $user_id]] ==0} { return }
		if {[ns_conn  method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
			set updateCriteria [SQLCriteria new -model $model]
			$updateCriteria addUpdateCriteria  item_id [$model get item_id]
			$updateCriteria addUpdateCriteria user_id [$model get user_id]
			set whereCriteria [SQLCriteria new -model $model]
			$whereCriteria add -includeTable 0 user_id	 $user_id
			$whereCriteria add -includeTable 0 item_id $item_id

			if {[$model updateMultipleRows $updateCriteria $whereCriteria]} {
				my redirect view user_id [$model get user_id] item_id [$model get item_id]
				return 1
			}
		}
		my render update model $model

	} 

	#or id as argument for this method
	:public method actionDelete {} {
		set id [ns_queryget id ]
		#TODO if not via POST..  give 400 error "invalid request"
		
	#TODO do intermediate step CONFIRMING the deletion..:D	
	#TODO or make undo button.. 
		#set model [my loadModel $id]
		if {[set model [my loadModel $id]] ==0} { return }

		set returnLoc [expr {[ns_queryexists returnUrl] ? "[ns_queryget returnUrl]" : "admin"}]
		if {[$model delete;]} {
		 	my render $returnLoc infoalert [list -type success [mc "Successfully deleted column with id %d. TODO click here to UNDO" $id]] model $model
		 }
	
	#TODO if AJAX request (triggered by deletion via admin grid view), we should not redirect the browser
		if {![ns_queryexists ajax]} {
			my redirect $returnLoc model $model
		}
		#TODO show page that you've deleted this..
	}
	

	:public method actionAdmin {} {
		set model [RoleAssignment new]
		#TODO unset any default values in model

		if {[ns_conn method] == "POST"} {
			$model getQueryAttributes POST
		}
		my render admin model $model 
	}

	:public method loadModel {item_id user_id} {
		set model [RoleAssignment new]
		$model setScenario "search"
		if {![string is double $item_id] || ![string is double $user_id] } {

			set result [$model searchByName $item_id $user_id]
		} else {
			set result [$model findByPk -relations 1 [list $item_id $user_id] ] 
		}

	#	$model set id $id 
	#	if {[set validation [$model validate id]] != 0} { 	my notFound  [msgcat::mc "Not validating, sorry! %s" $validation]; return 0 }


		if {$result == 0} {
			my notFound <br>[msgcat::mc "Tried to search for item_id %s and user_id %s but just couldn't find it!" $item_id $user_id ]
			return 0
		} else {  	return $model; }
	} 
	
}



