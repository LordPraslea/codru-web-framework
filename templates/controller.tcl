##########################################
# Controller Generation
##########################################

nx::Class create %controllerController -superclass Controller {

	:method init {} {
		set :layout layout
		#my	setLayout layout
	}

	:public method accessRules {} {
		# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
		# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
		# actions  
		return [dict create views { 
			view  { allow { users * } }	
			index { allow { users * } }	
			update { allow { users @ } }
			create { allow { users @ } }
			delete { allow { users @ } }
			admin { allow { users @ } }
		}   ]
	}

	:public method filters {} {
	
		return ""
	}

	:public method currentController {}	{
		return [string tolower %controller];	
	}
	
	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [%modelName new]
	}

	#method could have arguments as GET/POST 
	:public method actionView {} {
		set id [ns_queryget id 1 ]

		if {[set model [my loadModel $id]] ==0} { return }
		my render view model $model 
	}
	
	:public method actionCreate {} {
		set model [%modelName new]
		#$model nodjsRules $bhtml

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
		my render create model $model

	}

	:public method actionUpdate {} {
		set id [ns_get id ]
		if {[set model [my loadModel $id]] ==0} { return }
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
		my render update model $model

	} 


	:public method actionAdmin {} {
		set model [%modelName new]

		if {[ns_conn method] == "POST"} {
			$model getQueryAttributes POST
		}

		set extra ""
		 if {[ns_session contains infoalert]} {
			 set infoalert [ns_session get infoalert]
			 set extra "infoalert [list $infoalert]"
			 ns_session delete infoalert
		 } 	
		 my render admin model $model {*}$extra
	}

	:public	method loadModel {id {ajax 0}} {
		set model [%modelName new]
	
		if {$ajax} {
			set returnFunction :returnAjaxNotFound
		} else {  
			set returnFunction :returnNotFound
		}

		:loadModelEmptyId 
		:loadModelIsDouble

		$model setScenario "search"
		$model set id $id 
		:loadModelValidateId	

		:loadModelFindByPk
	} 


	
}


