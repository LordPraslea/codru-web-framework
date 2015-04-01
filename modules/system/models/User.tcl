#Model
nx::Class create User -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	
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
						string { on {login register} }
						required { on {login register} }
						between { rule "3 30"  on {login register} }
						unique { on register }
					}
				}
				password {
					unsafe { on {reset profileupdate} }
					validation {
						string { on {passwordprofileupdate resetpassword login register} }
						required {   on {passwordprofileupdate resetpassword login register} }
						min-length { rule 8  on {passwordprofileupdate resetpassword login register} }
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
						required { on {register reset} }
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
						captcha { on  {register reset login } }
					}
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

	:public method loadUserProfile { } {
		variable attributes
		variable alias
		set extrafields ""
			set pt [ProfileType new]
			set ptv [$pt search   ]
			#set ptv [$pt search  [list id name] ]
			set up [UserProfile new]
			foreach [dict get $ptv columns] [dict get $ptv values] {
				#validation
				 set fieldname [join [string tolower $name] _]
				dict set :attributes sqlcolumns $fieldname "  validation { $type { on { profileupdate } } }  " 
				dict set :attributes sqlcolumns $fieldname id $id
				dict set  :alias $fieldname $name
			#	my setAlias $fieldname $name
				lappend extrafields $id $fieldname
				lappend ptids $id
			}
			dict set attributes extrafields $extrafields
			#TODO FINISH THIS
			set upv [$up search -numericStmt 1 -where [list user_id [ns_session get userid]  ]]
		#	puts "profile type $ptv \nextra [dict get ${:attributes} extrafields] \n\n\n alias : [dict get $alias]"
		#	puts "$ptv and new upv $upv"
			if {$upv != ""} {
				foreach [dict get $upv columns] [dict get $upv values] {
					set fieldname [lindex $extrafields [lsearch $extrafields $profile_id]+1]
					dict set :attributes sqlcolumns $fieldname value $profile_value		
				}
			}
	}
	:public method saveUserProfile {} {
		 foreach {id field} [dict get ${:attributes} extrafields] {
			 set up [UserProfile new]
		 	set value [my get $field]
			$up set profile_id $id profile_value $value user_id [ns_session get userid]
			# We try to update it, if it doesn't work/exist we insert it
			if {![$up update]} {
				$up insert
			#	puts "Inserting $id"
			} else {
			#	puts "Updating $id"
			}

		 }
		 return 1
	}

	:public method changepassword {extra column value} {
		#Verify if the column is unique
		if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set column_name [my getAlias $column]

		set password [ns_sha1 [my get current_password]]
	#	my set password $password
		set u [User new]
		if {[$u findByCond [list  "password $password" "id [ns_session get userid]" ] ]} {
			 if {$password  != [$u get password]} {
				 return [msgcat::mc 	{Your current password isn't correct, try again.}	 $column_name $value] 
			 }
		
		} else {
				 return [msgcat::mc 	{Your current password isn't correct, try again.}	 $column_name $value] 
		}
		return 0

	}

	:public method login {} {
		if {[:validate] == 0} {
		 	set user_password [ns_sha1 [my get password]]	
			#you can either save the object with all details.. OR just select them..
			if {![:findByCond -save 1 [list username [my get username]] ]} {
				#set column_name [my getAlias $column]
				:addError username [msgcat::mc "This username doesn't exist"]
			#	puts "This username doesn't exist.."
				return 0
			} 

			#Next, verify if you're not "temporarily blocked"
		if {[clock scan  [getTimestamp]] < [clock scan [my get temp_login_block_until]]} {
			:addError password [msgcat::mc "This account is still temporarily blocked untill %s
				because someone tried too many wrong passwords.." [my get temp_login_block_until]]

			return 0
		}
			#TODO SHA1 or SHA2
			#sha2::sha256 
			#ns_sha1
			if {![string match $user_password [my get password]]} {
				:addError password [msgcat::mc "The password you entered is incorrect"]
				# limit 5 wrong passwords per 1-3 hours by blocking ip/user login and sending e-mail to inform user..
				set login_attempts [my get login_attempts]
				incr login_attempts
				:set login_attempts $login_attempts 
				puts "Login attempts $login_attempts"
				if {$login_attempts >=5} { 
					:set temp_login_block_until [getTimestamp [clock add [clock seconds] 3 hours]]
					:addError password [msgcat::mc "Nice going Sherlock, you've just temporarily blocked
					your account for 3 hours because you entered too many wrong passwords.."]
					#TODO send e-mail to inform user, with a link to "unblock" if it was him who did this!
				}
				:unset password
				:update
				return 0
			}
			#TODO verify if activated.. if not.. redirect to login.. ask to wait for email
			#alternatively you can log him in automatically.. and make it more user friendly
			#asking him to activate within 24/48 hours or he won't be able to login:)
		#TODO modify user last login time..
	 	if {[:get status] == 0} {
			:addError username [msgcat::mc "You can't login because you're banned! If you think this is a mistake, contact us."]
			return 0
		}	elseif {[my get status] == 1} {
			:addError username [msgcat::mc "You need to first activate your account before you login."]
			return 0
		}		

		set longlogin [:get longlogin]
		if {$longlogin != ""} {
		#	puts "Session with longlogin $longlogin"
			ns_session put longlogin true 
		}
		:unset longlogin
		ns_session put userid [my get id]
		ns_session put username [my get username] 
		ns_session put user_type [my get user_type] 
		#Update the last login time
		#TODO in future add login IP to another table..
		:set last_login_at [getTimestamp]
		:set login_attempts 0

		#$model set login_ip [ns_conn peeraddr] 
		:setScenario loginsave
		:save
		return 1
		#TODO redirection done in controller..:D
		#redirect to right page, either returnUrl or returnto session..
		#if both empty... return to view the normal page
		#		set returnto [ns_session get returnto]
		#if returning to returnto empty returnto
		# ns_returnredirect [ns_session get returnto [ns_conn location]]
		# 
		}
		return 0
	}

	:public method register {} {
	
	}
	
	:public method activate {} {
		

	}
	

}

