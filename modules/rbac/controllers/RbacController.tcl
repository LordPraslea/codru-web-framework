##########################################
# Controller Generation
##########################################

nx::Class create RbacController -superclass Controller {
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
			view  { allow { users @ } roles {superadmin rbac}  }	
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
		return [string tolower Rbac];	
	}
	
	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [RoleItem new]
	}

	#method could have arguments as GET/POST 
	:public method actionView {} {
		set id [ns_queryget id 1 ]

		if {[set model [my loadModel $id]] ==0} { return }
		my render view model $model 
	}
	
	#TODO if PK same when creating new, view if not unique constraing..
	:public method actionCreateRole {} {
		set model [RoleItem new]
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
				my redirect view id [$model get id] 
				return 1
			}

		}
		#using ns_adp_parse AND ns_adp_include
		my render create model $model

	}
	:public method actionCreateRoleChild {} {
		set model [RoleItemChild new]
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
				my redirect view id [$model get id] 
				return 1
			}

		}
		#using ns_adp_parse AND ns_adp_include
		my render create model $model

	}
	:public method actionAssignRole {} {
		set model [RoleItemChild new]
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
				my redirect view id [$model get id] 
				return 1
			}

		}
		#using ns_adp_parse AND ns_adp_include
		my render create model $model

	}

	#ruff
	#or arguments id? to be included for actionUpdate	
	:public method actionUpdate {} {
		set id [ns_get id ]
		if {[set model [my loadModel $id]] ==0} { return }
		#For when you want ajax/javascript validation.. (ajax validation not working atm)
		#$model nodjsRules $bhtml
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
		#	set errors [$model validate]
		#	puts "errors are $errors"
			#If it's ok to save it.. redirect to new 
			if {[$model save]} {
				my redirect view id $id
				return 1
			}
		}
	#	puts "Generating the update thingie.."
		#using ns_adp_parse AND ns_adp_include
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

#TODO find the best way to just stop execution without doing things like
#return -level 100 or ns_adp_return which gives error..
	:public method loadModel {id} {
		set model [RoleItem new]
		#set model [RoleAssignment new]
	
		#If id is empty (but query string contains data and it's a POST)
		#get the name of the classKey
		if {$id == ""} { set id [ns_queryget [$model classKey id]] }
		if {![string is double $id] && 0} {   
			my notFound <br>[msgcat::mc "Tried to search for id %d but just couldn't find it!" $id]
			return 0
		}
		$model setScenario "search"
		$model set id $id 
		if {[set validation [$model validate id]] != 0} { 	my notFound  [msgcat::mc "Not validating, sorry! %s" $validation]; return 0 }
		if {[$model findByPk $id] == 0} {
			#verify if model is not null eg if it exists
			#	if null throw exception which means generate an  404 error
			my notFound <br>[msgcat::mc "Tried to search for id %d but just couldn't find it!" $id]
			return 0
		#	return $model
		#	ns_adp_close ;#this closes the adp connection but the functions keep on going!
		} else {  	return $model; }
	
	} 

	:public method performAjaxValidation {model} {
		if {0} {
			if(isset($_POST['ajax']) && $_POST['ajax']==='posts-form')
			{
				echo CActiveForm::validate($model);
				Yii::app()->end();
			}
		}
	}
	
}



