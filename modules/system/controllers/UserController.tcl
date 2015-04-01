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

	:public method actionLang {} {
		#Using dataprovider and loading from database COMMENT?

		set supportedlang "en ro nl"
		set supportedlanguages "English Română Nederlands"

		if {[ns_conn method] == "GET" && [ns_queryexists lang]} {
			#Set optional value the one from the configuration instead of english?
			set lang [ns_queryget lang en]
			if {[lsearch $supportedlang $lang] == -1} { set lang en }	
			#TODO if logged in save his choice OR set his choice in the database in profile:D	
			
			#Set the session, cookie & locale with the current correct language,  
			ns_log debug "Changed language to $lang"
			ns_session put lang $lang
			ns_setcookie -path / lostmvc_lang $lang 
			msgcat::mclocale $lang

			set infoalert [list -type success [mc "Your language settings have been changed to English"] ]
		
			my render lang infoalert $infoalert 
			return 1
		}
		my render lang  
	}

		#TODO if PK same when creating new, view if not unique constraing..
	
	:public method actionRegister {} {
			my redirectLogin
		set model [User new]
		#set bhtml [bhtml new]

		#For when you want ajax validation..
		#$model nodjsRules $bhtml

		#If POST...
		$model setScenario register
		if {[ns_conn method] == "POST"} {
		#	puts "Yeah, creating a new thingie here!"
			set queryattributes [$model getQueryAttributes POST ]
			#Encrypt password..
			set password [$model get password]
			if {$password != ""} {
			$model set password [ns_sha1 [$model get password]]
			}
		#	$model set creation_at [clock milliseconds]
			$model set activation_code [generateCode 13]
			$model set creation_at [getTimestamp]
			$model set creation_ip [ns_conn peeraddr] 
			#TODO future add regIp to db..
			#set errors [$model validate]
			#puts "errors are $errors"
			if {[$model save]} {
				#Using e-mail template to send mail with activation link..:D
				#
				#
				set bhtml [bhtml new]
				set jumbotron [$bhtml jumbotron [msgcat::mc "Account created successfully"]  [msgcat::mc "You've successfully registered. 
				You will recieve an e-mail with an activation link.
				Please click on it to activate your account and start saving time."]]

				my simpleRender $jumbotron
				#my redirect view id [$model get id] 
				set activationlink [ns_conn location]/user/activate?code=[$model get activation_code]
				set f [open [ns_server pagedir]/modules/system/views/user/register_email.adp r]
				set email_template [read $f]
				set email_data [string map "%username [$model get username]  %sitename [dict get $config names sitename ]  %password [$model get password] %activationlink $activationlink" $email_template ]
				close $f

				set config [ns_cache_get lostmvc config.[getConfigName]] 

				send_mail [$model get email] "[dict get $config names sitename ] <[dict get $config email]>" \
					[msgcat::mc "Your new account at %s" [dict get $config names website]] $email_data  

			#	$model register
				return [$model get id]
			}
		}
		$model set password ""
		#using ns_adp_parse AND ns_adp_include
		my render register model $model
	}

	:public method actionLogin {} {
			my redirectLogin
		set model [User new]
		#set bhtml [bhtml new]

		#For when you want ajax validation..
		#$model nodjsRules $bhtml
		$model setScenario login
		if {[ns_conn method] == "POST"} {
		#	puts "Yeah, creating a new thingie here!"
			set queryattributes [$model getQueryAttributes POST]
			#Login Function and send him on his way!
			if {[$model login]} {
				if {[ns_session contains returnto]} {
					set returnto [ns_session get returnto]
					ns_session delete returnto
					if {![string match *user/login* $returnto]} {
						puts "Returning to $returnto"
						ns_returnredirect $returnto
						return 1
					}
				} 
					
					#my redirect view id [$model get id] ;#old value
					my redirect profile
				return 1
			}
		}
		#using ns_adp_parse AND ns_adp_include
		my render login model $model
	}
	
	:public method actionActivate {} {
			my redirectLogin
		set model [User new]
		$model setScenario activate

		if {[ns_conn method] == "GET" && [ns_queryexists code]} {
			set bhtml [bhtml new]
			set code [ns_queryget code]
			#TODO separate function in Model?
			#TODO better to split this in views....?
			if {![$model findByCond -save 1 [list activation_code $code]]} {
				set jumbotron [$bhtml jumbotron [msgcat::mc  "Activation code incorrect."]  [msgcat::mc "No such activation code seems to exist"]]
				my simpleRender $jumbotron
				return 0
			} 
			if {[$model get status] != 1} {
				set alreadybody [msgcat::mc "This account is already activated, you don't need to activate it again.."]
				set jumbotron [$bhtml jumbotron [msgcat::mc  "Account is already activated."] $alreadybody  ]
				my simpleRender $jumbotron
				#	my render login model $model extrainfo $jumbotron
				return 0
			}
			#Unset password.. so no "hackattempt" 
			$model unset password 
			$model set status 2
			$model set last_login_at [getTimestamp]
			#Using update instead of save because "save" does validation which is not needed..
			$model update

			#TODO If settings for autoLoginAfterActivate = true
			#then autologin username.. 
			if {1} {
				ns_session put userid [$model get id] 
				ns_session put username [$model get username] 
				ns_session put user_type [$model get user_type] 

				if {[ns_session contains returnto]} {
					set returnto [ns_session get returnto]
					ns_session delete returnto 
					#ns_returnredirect [ns_session get returnto] 
					if {![string match *user/login* $returnto]} { 
						ns_returnredirect $returnto 
						return 0
					}
				} 
				#my redirect view id [$model get id]
				my redirect profile 
				
			#	set extrainfo [$bhtml ]
			} else {
			#Else just redirect to Login Page

				my render login model $model extrainfo [$bhtml alert [msgcat::mc  "You've successfully activated your account. You may now login!"]] 
			}
			return 1

		}

		#using ns_adp_parse AND ns_adp_include
		my render login model $model
	}
	
	:public method actionReset {} {
			my redirectLogin
		#Resetting the password
		#first showing form.. 
		set model [User new]
		#For when you want ajax validation..
		#$model nodjsRules $bhtml
		$model setScenario reset
		if {[ns_conn method] == "POST"} {
		#	puts "Yeah, creating a new thingie here!"
			set queryattributes [$model getQueryAttributes POST]
			#$model validate email	
			#	puts [$model getScenarioKeys]
			set email [$model get email]
			if {[string match "*@*" $email ]} {
				set tomatch email
			} else { set tomatch username }

			if {![$model findByCond -save 1 [list $tomatch $email]]} {
				$model addError email [msgcat::mc "No such username or e-mail can be found!"]	
				
			}
			set password_at [$model get password_reset_at]
			if {$password_at != ""} {
				if {([scanTz  [getTimestamp]] < [clock add [scanTz $password_at] 3 hours])} {
					$model addError email [msgcat::mc  "A password reset has already been requested some time ago.
					You need to wait 3 hours between consequent password resets. Did you verify your e-mail? "]
				}
			}
			$model setScenario reset
		#	$model validate captcha

	#	if {[$model validate captcha] == 0} {
	#		puts "Validation ok..? [$model getScenario]"
	#	}
		#	puts " password at $password_at time [clock scan  [getTimestamp]] time [clock add [clock scan $password_at] 3 hours] errors [$model getErrors] "
			if {[$model getErrors] == ""} {
				$model set password_code [generateCode 13]	
				$model set password_reset_at [getTimestamp]
				#TODO verify if something is wrong or not..
				$model save

				set bhtml [bhtml new]
				set msgbody [msgcat::mc "You will recieve an e-mail with an password reset link.
				Please click on it to change your account's password."]
				set jumbotron [$bhtml jumbotron [msgcat::mc "Reset e-mail sent successfully"] $msgbody  ]


				my simpleRender $jumbotron
				#my redirect view id [$model get id] 
				set activationlink [ns_conn location]/user/resetPassword?code=[$model get password_code]
				set f [open [ns_server pagedir]/modules/system/views/user/reset_password_email.adp r]
				set email_template [read $f]
				set email_data [string map "%username [$model get username]   %sitename [dict get $config names sitename ] %activationlink $activationlink" $email_template ]
				close $f

				send_mail [$model get email] "[dict get $config names sitename ] <[dict get $config email]>" 	[msgcat::mc "Resetting your password at %s" [dict get $config names website]] $email_data  
				return 1
			}

		} 	
		#using ns_adp_parse AND ns_adp_include
		my render reset model $model
	}

	:public method actionResetPassword {} {
			my redirectLogin
		set model [User new]

		#set code [ns_get code]
		if {[set code [ns_get code]] != "" && $code != "reset"} {
		
			if {[$model findByCond  [list password_code $code]]} {
					
				$model setScenario resetpassword
				if {[ns_conn method] == "POST"} {
					
					set queryattributes [$model getQueryAttributes POST]
					set validate [$model validate]
				#	puts [$model getScenarioKeys]
			#	puts "My errors [$model getErrors]"

					if {[string is space [$model getErrors]] && $validate ==0} {
						#set new timestamp (so if resetting.. sorry, wait again!)
						#Password_code set to 0 so you can't use it again after 3 hours:)
						#You could simply use another if to verify if it passed 24-48 hours..
						$model set password_reset_at [getTimestampTz]
						$model set password_code "reset"
						$model set password [ns_sha1 [$model get password]]
						$model set retype_password [ns_sha1 [$model get retype_password]]

						$model setScenario reset_password_ok
						#puts "Model validate $validate [$model get retype_password] and original [$model get password] "
						#TODO auto login?
						#
						$model unset retype_password
						$model save
							my errorPage [msgcat::mc "Your password has been successfully changed."] [msgcat::mc "You've changed your password, you may now login!"]
							return 1  
					}
				}
				$model set password ""
				$model set retype_password ""
				my render reset_password model $model
				return 1
			} else { my errorPage [msgcat::mc "This code doesn't exist"] [msgcat::mc "Sorry this reset password code doesn't exist.."] }
		} 
		my render reset model $model
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
		#Load all profiles, check them against the userid + profile id..
		#create forms and show them

		$userprofilemodel loadUserProfile	
		$userprofilemodel genScenarios
		if {[ns_conn method] == "POST"} {
			set update_type [ns_queryget update_type profileupdate]

			if {$update_type == "password"} {
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
					#	$model set password "" retype_password "" current_password ""
						my render profileupdate model $model userprofilemodel $userprofilemodel infoalert $infoalert  ;#id $id
						return 1
					}

				} 
			} else { 
				$userprofilemodel setScenario profileupdate
				$userprofilemodel getQueryAttributes POST 

				puts "[$userprofilemodel getScenario]"
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
		}
		my render profileupdate model $model userprofilemodel $userprofilemodel

	} 

	:public method actionUpdate {} {
		#TODO change password/change e-mail
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
		 	my render $returnLoc infoalert [list -type success "Successfully deleted column with id $id. TODO click here to UNDO"] model $model
		 }
	
	#TODO if AJAX request (triggered by deletion via admin grid view), we should not redirect the browser
		if {![ns_queryexists ajax]} {
			my redirect $returnLoc model $model
		}
		#TODO show page that you've deleted this..
	}
	

	:public method actionAdmin {} {
		set model [User new]
		#TODO unset any default values in model

		if {[ns_conn method] == "POST"} {
			$model getQueryAttributes POST
		}
		my render admin model $model 
	}

#TODO find the best way to just stop execution without doing things like
#return -level 100 or ns_adp_return which gives error..
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

	:public method performAjaxValidation {model} {
		if {0} {
			if(isset($_POST['ajax']) && $_POST['ajax']==='posts-form')
			{
				echo CActiveForm::validate($model);
				Yii::app()->end();
			}
		}
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

	#	ns_puts "url is $url <br> action $action"
		my notFound

	}
	
}



