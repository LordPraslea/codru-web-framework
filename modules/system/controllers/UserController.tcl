##########################################
# Controller Generation
##########################################

nx::Class create UserController -superclass Controller {
#	variable layout

	:method init {} {
		#set attributes { %s }  
		#next $attributes $alias
		set :layout column2
		#my	setLayout layout
	}

	:public method accessRules {} {
		# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
		# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
		# actions  
		# allow user to do the following only on his own profile:
		# view, update, (delete..?)
		return { views { 
			register { allow { users * } }
			login { allow { users * } }
			activate { allow {users * } }
			logout { allow { users * } }
			resetpassword { allow { users * } }
			reset { allow { users * } }
			lang { allow { users * } }
			view  { allow { users @ } roles {  superadmin} }	
			profile  { allow { users @ }  }	
			profileupdate  { allow { users @ }  }	
			index { allow { users @ } roles {superadmin} }	
			update { allow { users @ } roles { isSelf superadmin } }
			delete { allow { users @ } roles { superadmin } }
			create { allow { users @ } roles { superadmin } }
			admin { allow { users @ } roles { superadmin } }
			captcha { allow {users *} }
		} 
		rbac  { no } }
	}

	:public method filters {} {
	
		return ""
	}

	:public method currentController {}	{
		return [string tolower User];	
	}

	:public method notadmin {} {
		#Example how to set advanced roles..
		if {[ns_session get username]=="lostone"} {
			return 1
		} else { return  0}
	}	

	:public method actionCaptcha {} {
		my captcha "nocalc" 
	}

	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [User new]
	}

	#method could have arguments as GET/POST 
	:public method actionView {} {
		set id [ns_queryget id [ns_session get userid ]]

		if {[set model [my loadModel $id]] ==0} { return }
		my render view model $model 
	}
	


		#TODO if PK same when creating new, view if not unique constraing..
	
	:public method actionRegister {} {
		my redirectLogin
		set model [User new]

		$model setScenario register
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST]
			set msg [msgcat::mc "You've successfully registered."] 
			if {[$model validate] == 0} {
				:setRegisterModelInformation
				if {[$model save]} {
					set bhtml [bhtml new]

					if {[:autoLoginAfterActivation]} {
						:activateAutoLogin
						:loginRedirect
					} else {
						set jumbotron [$bhtml jumbotron [msgcat::mc "Account created successfully"] $msg  ]
						:simpleRender $jumbotron
					}

					:sendRegisterEmail
					return [$model get id]
				}
			}
		}
		$model set password ""
		#using ns_adp_parse AND ns_adp_include
		my render register model $model
	}

	:method setRegisterModelInformation {args} {
		:upvar model model msg msg
		#Encrypt password..
		set password [$model get password]
		if {$password != ""} {
			$model set password [ns_sha1 [$model get password]]
		}
		#	$model set creation_at [clock milliseconds]
		$model set activation_code [generateCode 13]
		$model set creation_at [getTimestamp]
		$model set creation_ip [ns_conn peeraddr] 

		set activate [mc "You will recieve an e-mail with an activation link."]	
		set config [ns_cache_get lostmvc config.[getConfigName]] 
		if {[dict exists $config autoActivateAccount]} {
			if {[dict get $config autoActivateAccount]} {
				$model set status 2
				set activate [mc "Your may now login!"]	 
			}
		}
		append msg "  " $activate
	}

	:method sendRegisterEmail {  } {
		:upvar model model
		set config [ns_cache_get lostmvc config.[getConfigName]] 
		set activationlink [ns_conn location]/user/activate?code=[$model get activation_code]
		set templateData 	"%username [$model get username]  %sitename [dict get $config names sitename ]
			%password [$model get password] %activationlink $activationlink"
		set	emailTemplate [:getDataFromTemplate /modules/system/views/user/register_email.adp $templateData]

		send_mail [$model get email] "[dict get $config names sitename ] <[dict get $config email]>" \
			[msgcat::mc "Your new account at %s" [dict get $config names website]] $emailTemplate  
	}



	:public method actionLogin {} {
		my redirectLogin
		set model [User new]

		$model setScenario login
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST]
			#Login Function and send him on his way!
			if {[$model login]} {
				:loginRedirect
			}
		}
		my render login model $model
	}

	:method loginRedirect {  } {
		if {[ns_session contains returnto]} {
			set returnto [ns_session get returnto]
			ns_session delete returnto
			if {![string match *user/login* $returnto]} {
				ns_returnredirect $returnto
				return -level 2 1
			}
		} 

		set config [ns_cache_get lostmvc config.[getConfigName]] 
		if {[dict exists $config redirectLogin ]} {
			:redirect {*}[dict get $config redirectLogin]
		} else {
			my redirect profile
		}
		return -level 2 1
	}


	:public method actionActivate {} {
		my redirectLogin
		set model [User new]
		$model setScenario activate

		if {[ns_conn method] == "GET" && [ns_queryexists code]} {
			set bhtml [bhtml new]
			:verifyActivationCode
			:verifyAccountActivated
		
			:activateSetModel	

			if {[:autoLoginAfterActivation]} {
					:activateAutoLogin
					:loginRedirect
			} else {
				my render login model $model extrainfo [$bhtml alert [msgcat::mc  "You've successfully activated your account. You may now login!"]] 
			}
			return 1
		}
		my render login model $model
	}

	:method verifyActivationCode {  } {
		:upvar model model
		set code [ns_queryget code]
		set criteria [SQLCriteria new -model $model]
		$criteria add activation_code $code
		if {![$model findByCond -save 1  $criteria ]} {
			set jumbotron [$bhtml jumbotron [msgcat::mc  "Activation code incorrect."]  [msgcat::mc "No such activation code seems to exist"]]
			my simpleRender $jumbotron
			return -level 2 0
		} 
	}

	:method verifyAccountActivated { } {
		:upvar model model
		if {[$model get status] != 1} {
			set alreadybody [msgcat::mc "This account is already activated, you don't need to activate it again.."]
			set jumbotron [$bhtml jumbotron [msgcat::mc  "Account is already activated."] $alreadybody  ]
			my simpleRender $jumbotron
			#	my render login model $model extrainfo $jumbotron
			return -level 2 0
		}
	}

	:method activateSetModel {  } {
		:upvar model model	 
		#Unset password.. so no "hackattempt" 
		$model unset password 
		$model set status 2
		$model set last_login_at [getTimestamp]
		#Using update instead of save because "save" does validation which is not needed..
		$model update
	}

	:method  autoLoginAfterActivation {} {
		set config [ns_cache_get lostmvc config.[getConfigName]] 
		if {[dict exists $config autoLoginAfterActivation]} {
			return [dict get $config autoLoginAfterActivation]
		}
		return 0
	}

	:method activateAutoLogin {  } {
		:upvar model model
		ns_session put userid [$model get id] 
		ns_session put username [$model get username] 
		ns_session put user_type [$model get user_type] 
	}

	#Password Reset form fill to send e-mail
	:public method actionReset {} {
		my redirectLogin
		set model [User new]
		$model setScenario reset

		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST]

			:verifyResetDetails
			$model setScenario reset

			if {[$model getErrors] == ""} {
				:setModelForReset
				:renderResetSuccessful
				:sendResetPaswordEmail	
				return 1
			}
		} 	
		my render reset model $model
	}

	:method verifyResetDetails {  } {
		:upvar model model
		 	set email [$model get email]
			if {[string match "*@*" $email ]} {
				set tomatch email
			} else { set tomatch username }
			set criteria [SQLCriteria new -model $model]
			$criteria add $tomatch $email

			if {![$model findByCond -save 1 $criteria ]} {
				$model addError email [msgcat::mc "No such username or e-mail can be found!"]	
			}

			set password_at [$model get password_reset_at]
			if {$password_at != ""} {
				if {([scanTz  [getTimestamp]] < [clock add [scanTz $password_at] 3 hours])} {
					$model addError email [msgcat::mc  "A password reset has already been requested some time ago.
					You need to wait 3 hours between consequent password resets. Did you verify your e-mail? "]
				}
			}
	}
	

	:method setModelForReset {  } {
		:upvar model model
		$model set password_code [generateCode 13]	
		$model set password_reset_at [getTimestamp]
		#TODO verify if something is wrong or not..
		$model save
	}

	:method renderResetSuccessful {  } {
		 
				set bhtml [bhtml new]
				set msgbody [msgcat::mc "You will recieve an e-mail with an password reset link.
				Please click on it to change your account's password."]
				set jumbotron [$bhtml jumbotron [msgcat::mc "Reset e-mail sent successfully"] $msgbody  ]
				my simpleRender $jumbotron
	}
	:method sendResetPaswordEmail {  } {
		:upvar model model

		set config [ns_cache_get lostmvc config.[getConfigName]] 

		set activationlink [ns_conn location]/user/resetPassword?code=[$model get password_code]
		set templateData  "%username [$model get username]   %sitename [dict get $config names sitename ] 
		%activationlink $activationlink"
		set	emailTemplate [:getDataFromTemplate /modules/system/views/user/reset_password_email.adp $templateData]
		send_mail [$model get email] "[dict get $config names sitename ] <[dict get $config email]>" [msgcat::mc "Resetting your password at %s" [dict get $config names website]] $emailTemplate  

	}

	#Password reset
	:public method actionResetPassword {} {
		my redirectLogin
		set model [User new]

		if {[set code [ns_get code]] != "" && $code != "reset"} {
		
			set criteria [SQLCriteria new -model $model]
			$criteria add password_code $code
			if {[$model findByCond  $criteria ]} {
				:resetPasswordVerification

			} else { my errorPage [msgcat::mc "This code doesn't exist"] [msgcat::mc "Sorry this reset password code doesn't exist.."] }
		} 
		my render reset model $model
	}

	:method resetPasswordVerification {} {
		:upvar model model

		$model setScenario resetpassword
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST]
			set validate [$model validate]

			:resetPasswordVerifyValidationErrors
		}

		$model set password ""
		$model set retype_password ""
		my render reset_password model $model
		return -level 2 1
	}

	#set new timestamp (so if resetting.. sorry, wait again!)
	#Password_code set to 0 so you can't use it again after 3 hours:)
	#You could simply use another if to verify if it passed 24-48 hours..
	#TODO auto login?
	:method resetPasswordVerifyValidationErrors {  } {
	   foreach refVar {model validate} { :upvar $refVar $refVar }

		if {[string is space [$model getErrors]] && $validate ==0} {
			$model set password_reset_at [getTimestampTz]
			$model set password_code "reset"
			$model set password [ns_sha1 [$model get password]]
			$model set retype_password [ns_sha1 [$model get retype_password]]

			$model setScenario reset_password_ok
			
			$model unset retype_password
			$model save
			my errorPage [msgcat::mc "Your password has been successfully changed."] [msgcat::mc "You've changed your password, you may now login!"]
			return -level 3 1  
		}
	}

	:public method actionLogout {} {
	#	puts "Logging out!"
		ns_session destroy
		ns_returnredirect [ns_conn location]/user/login
	}

	:public method actionProfile {} {
		set id [ns_session get userid ]
		if {[set model [my loadModel $id]] ==0} { return }
		my render profile model $model 
	}
	
	:public method actionProfileUpdate {} {
		set id [ns_session get userid ]
		if {[set model [my loadModel $id]] ==0} { return }
		set userprofilemodel [User new]

		#Load all profiles, check them against the userid + profile id..  #create forms and show them
		$userprofilemodel loadUserProfile	
		$userprofilemodel genScenarios
		if {[ns_conn method] == "POST"} {
			set update_type [ns_queryget update_type profileupdate]

			if {$update_type == "password"} {
				:profileUpdatePassword
			} else { 
				:profileUpdateData
			}
		}
		my render profileupdate model $model userprofilemodel $userprofilemodel
	} 

	:method profileUpdatePassword {  } {
	   foreach refVar {model userprofilemodel} { :upvar $refVar $refVar }

		$model setScenario passwordprofileupdate
		$model loaddata 0

		set queryattributes [$model getQueryAttributes POST ]
		if {[$model validate] ==0} {
			$model unset retype_password
			$model unset current_password
			$model setScenario other
			$model set password [ns_sha1 [$model get password]]
			set infoalert [list -type success [mc "Successfully changed your password."]]
			if {[$model save]} {
				my render profileupdate model $model userprofilemodel $userprofilemodel infoalert $infoalert  ;#id $id
				return 1
			}
		} 
	}

	:method profileUpdateData {  } {
		foreach refVar {userprofilemodel model} { :upvar $refVar $refVar }

		$userprofilemodel setScenario profileupdate
		$userprofilemodel getQueryAttributes POST 

		#puts "[$userprofilemodel getScenario]"
		set infoalert [list -type success [mc "Successfully saved all profile data."]]
		if {[$userprofilemodel validate] == 0} {
			if {[$userprofilemodel saveUserProfile]} {
			#INSERT if not existing, update otherwise..
			#	$model set password "" retype_password "" current_password ""
				my render profileupdate model $model userprofilemodel $userprofilemodel infoalert $infoalert  ;#id $id
				return 1
			}
		}
	}

	:public method actionUpdate {} {
		set id [ns_get id ]
		if {[set model [my loadModel $id]] ==0} { return }
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
			if {[$model save]} {
				my redirect view id $id
				return 1
			}
		}
		my render update model $model
	} 


	:public method actionAdmin {} {
		set model [User new]
		#TODO unset any default values in model

		if {[ns_conn method] == "POST"} {
			$model getQueryAttributes POST
		}
		my render admin model $model 
	}

	:public method loadModel {id} {
		set model [User new]
	
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

	:public method actionCreate {} {
		set model [User new]

		$model setScenario create
		if {[ns_conn method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
			puts "action user create attributes $queryattributes"
			if {[$model get password] !=""} {
				set password [$model get password]
				$model set password [ns_sha1 [$model get password]]
			} else {
				set password [generateCode 10 3]
				$model set password [ns_sha1 $password]
			}

			$model set status 2

			if {[$model save]} {
				my redirect view id [$model get id] 
				:sendCreateAccountEmail
				return 1
			}

		}
		my render create model $model

	}

	:method sendCreateAccountEmail {  } {
		:upvar model model password password
		set config [ns_cache_get lostmvc config.[getConfigName]] 
		set templateData 	"%username [$model get username]  %sitename [dict get $config names sitename ]
			%password $password"
		set	emailTemplate [:getDataFromTemplate /modules/system/views/user/create_account_email.adp $templateData]

		send_mail [$model get email] "[dict get $config names sitename ] <[dict get $config email]>" \
			[msgcat::mc "Your new account at %s" [dict get $config names website]] $emailTemplate  
	}



	:public method  redirectLogin {} {
		if {[my verifyAuth]} {
			my redirect profile ; #view id [ns_session get userid]	
			return 1
		}
	}
	:public method defaultNotFound {} {
		set url [ns_conn url]
		set action [string tolower [lindex [join [split $url /]] 1]]

		my notFound
	}
	
}



