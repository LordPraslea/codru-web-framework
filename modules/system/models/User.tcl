#Model
nx::Class create User -superclass [list Model] {
	
	:method init {} {
		if {0} {
			validation {
						string { on {login register} }
						required { on {login register} }
						between { rule "3 30" on {login register} }
						unique { on register }
					}
		unsafe { on update }
					validation {
						string { on all }
						required { on all }
						between { rule "3 30"  }
						unique { on register }
					}
		}
		set :attributes { 
			table users
			primarykey id
			sqlcolumns {
				id {
					unsafe { on all }
					validation {
						integer { on search }
					}
				}
				username {
					unsafe { on {update reset reset_password passwordprofileupdate profileupdate } }
					validation {
						string { on {login register create} }
						required { on {login register create} }
						between { rule "3 30"  on {login register} }
						unique { on register }
					}
				}
				password {
					unsafe { on {reset profileupdate} }
					validation {
						string { on { passwordprofileupdate resetpassword login register create } }
						required {   on { passwordprofileupdate resetpassword login register }  }
						min-length { rule 8  on { passwordprofileupdate resetpassword login register } }
					}
				}
				retype_password {
					validation { same-as { on { resetpassword passwordprofileupdate } rule password }	}
				}
				current_password {
					validation { 
						required { on { passwordprofileupdate } }
						min-length { on { passwordprofileupdate } rule 8 }
						changepassword { on { passwordprofileupdate } }
					}
				}

				email {
					validation {
						email { on {register}  }
						string { on register }
						required { on {register reset create} }
						unique { on register }
					}
				}
				last_login_at {
					unsafe { on all }
				
				}
				creation_at {
					unsafe { on all }
				
				}
				activation_code {
					unsafe { on all }
				
				}
				status {
					unsafe { on all }
					validation { integer { on activate } }
				}
				password_reset_at { unsafe { on all } }
				password_code { unsafe { on all } }
				creation_ip { unsafe { on all } }
				login_attempts { unsafe { on all } }
				temp_login_block_until { unsafe { on all } }
				user_type {
					validation { 
						integer { on {create edit}  }	
					} 
				}
				captcha {
					validation {
						captcha { on  {register reset login } rule  css-login    }
					}
					save false
				}
				longlogin {
					validation {
						string { on login } 
					}	
					save false
				}
				agree {
					validation {
						required { on register }
					}
					save false
				}
				language {
					validation {
						text { on  {profile  } }
					}
				}
				timezone {
					validation {
						text { on  {profile  } }
					}
				}
				telephone {
					validation { string { on register } } 
				}
				credits { 	validation { string { on create } } }

			}
 }  
		set :alias { 
			id Id
			username Username
			password Password
			current_password "Current password"
			retype_password "Retype password"
			email E-mail
			last_login_at {Last login at}
			creation_at {Creation at}
			activation_code {Activation code}
			status Status
			user_or_email {Username or E-mail}
			user_type {User Type}
			longlogin "Keep me logged in for 48 hours. (This is a private computer)"
			agree "I agree to the terms and conditions of this website."
			timezone Timezone
			language Language
 }
			#set db dbipg2
		next 
	}

	:public method findByUserOrId { user } {
		if {[string is integer $user]} {
			return [:findByPk $user]
		} else {
			set criteria [SQLCriteria new -model [self]]
			$criteria add username $user
			return [:findByCond $criteria]
		}
	}
	
	:public method existsUser {extra column value} {

	
	}

	:public method loadUserProfile { } {
		set extrafields ""
			set pt [ProfileType new]
			set ptvalues [$pt search   ]
			set up [UserProfile new]

			:setupValidationForUserProfile $ptvalues

			#TODO FINISH THIS
			set criteria [SQLCriteria new -model $up]
			$criteria add user_id [ns_session get userid]
			set upvalues [$up search -criteria $criteria]
			if {$upvalues != ""} {
				foreach [dict get $upvalues columns] [dict get $upvalues values] {
					set fieldname [lindex $extrafields [lsearch $extrafields $profile_id]+1]
					dict set :attributes sqlcolumns $fieldname value $profile_value		
				}
			}
	}

	#columns id type name required
	:method setupValidationForUserProfile {profileTypeValues} {
		upvar extrafields extrafields
			foreach [dict get $profileTypeValues columns] [dict get $profileTypeValues values] {
				#setup validation
				set fieldname [join [string tolower $name] _]
				dict set :attributes sqlcolumns $fieldname "  validation { $type { on { profileupdate } } }  " 
				dict set :attributes sqlcolumns $fieldname id $id
				dict set  :alias $fieldname $name
			#	my setAlias $fieldname $name
				lappend extrafields $id $fieldname
				lappend ptids $id
			}
			dict set :attributes extrafields $extrafields
	}

	:public method saveUserProfile {} {
		foreach {id field} [dict get ${:attributes} extrafields] {
			set up [UserProfile new]
			set value [my get $field]
			$up set profile_id $id profile_value $value user_id [ns_session get userid]
			# We try to update it, if it doesn't work/exist we insert it
			if {![$up update]} {
				$up insert
			}	
		}
		return 1
	}
	
	#Validation Method
	:public method changepassword {extra column value} {
		#Verify if the column is unique
		if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set column_name [my getAlias $column]
		set password [ns_sha1 [my get current_password]]

		set u [User new]
		set criteria [SQLCriteria new -model $u]
		$criteria add password $password
		$criteria add id [ns_session get userid]

		if {[$u findByCond $criteria ]} {
			 if {$password  != [$u get password]} {
				 return [msgcat::mc 	{Your current password isn't correct, try again.}	 $column_name $value] 
			 }
		} else {
				 return [msgcat::mc 	{Your current password isn't correct, try again.}	 $column_name $value] 
		}
		return 0
	}

	#
	# == Login handling
	#
	:public method login {} {
		if {[:validate] == 0} {
			set :user_password [ns_sha1 [my get password]]	
			:loginVerifyUsername
			:loginVerifyTemporaryBlocked	
			:loginVerifyPassword 

			:loginVerifyStatus 	
			:loginHandleLongLogin
			:loginSaveSession

			#$model set login_ip [ns_conn peeraddr] 
			:setScenario loginsave
			:save
			return 1
		}
		return 0
	}

	:method loginVerifyUsername {} {
		set criteria [SQLCriteria new -model [self]]
		$criteria add username [:get username]
		if {![:findByCond -save 1 $criteria ]} {
			:addError username [msgcat::mc "This username doesn't exist"]
			return -level 2 0
		} 
	}

	#Next, verify if you're not "temporarily blocked"
	:method loginVerifyTemporaryBlocked {  } {
		if {[clock scan  [getTimestamp]] < [scanTz [:get temp_login_block_until]]} {
			:addError password [msgcat::mc "This account is still temporarily blocked untill %s
			because someone tried too many wrong passwords.." [my get temp_login_block_until]]
			return -level 2 0
		}

	}

	:method loginVerifyPassword {  } {
		if {![string match ${:user_password} [:get password]]} {
			:addError password [msgcat::mc "The password you entered is incorrect"]
			# limit 5 wrong passwords per 1-3 hours by blocking ip/user login and sending e-mail to inform user..
			set login_attempts [my get login_attempts]
			incr login_attempts
			:set login_attempts $login_attempts 
			
			if {$login_attempts >=5} { 
				:set temp_login_block_until [getTimestampTz [clock add [clock seconds] 3 hours]]
				:addError password [msgcat::mc "Nice going Sherlock, you've just temporarily blocked
				your account for 3 hours because you entered too many wrong passwords.."]
				#TODO send e-mail to inform user, with a link to "unblock" if it was him who did this!
			}
			:unset password ;#Unset password that we just got form findByCond
			:update
			return -level 2 0
		}
	}

	:method loginVerifyStatus {  } {
		if {[:get status] == 0} {
			:addError username [msgcat::mc "You can't login because you're banned! If you think this is a mistake, contact us."]
			return -level 2 0
		}	elseif {[my get status] == 1} {
			:addError username [msgcat::mc "You need to first activate your account before you login."]
			return -level 2 0
		}		
	}
	:method loginHandleLongLogin {  } {
		set longlogin [:get longlogin]
		if {$longlogin != ""} {
			ns_session put longlogin true 
		}
		:unset longlogin
	}

	:method loginSaveSession {  } {
		set userid [my get id]
			ns_session put userid $userid
			ns_session put username [my get username] 
			ns_session put user_type [my get user_type] 
		
			set timestamp [getTimestampTz]
			:set last_login_at $timestamp
			:set login_attempts 0

			set login_ip [ns_conn peeraddr] 

			dbi_dml -db [:db get] "INSERT INTO login_stats VALUES (:userid,:timestamp,:login_ip)"
	}



	:public method register {} {
	
	}
	
	:public method activate {} {
		

	}
	

}

