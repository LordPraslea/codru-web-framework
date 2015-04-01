##########################################
# Controller Generation
##########################################

nx::Class create PaypalController -superclass ::Controller {
	#variable layout
	:variable settings
	:variable urls

	::public method init {} {
		#set attributes { %s }  
		
		#next $attributes $alias
		set :layout column2
		#my	setLayout layout
		set :urls {
			access	/v1/oauth2/token
			payment /v1/payments/payment

			return_url /paypal/finished
			cancel_url /paypal/cancel
		}
		set settings_sandbox {
		  endpoint https://api.sandbox.paypal.com
		  clientid  AR603xCJVZjkrI57yYJDGuGfgiBMJSI-fnIz882N3pSQw7QLZDumh1jv9ueA
		  secret EDH-2RC0ViC6ya-FME_Yzk0Taak1hSX5W3rl0EreJ62nPdRvAm7fzfMA3Rwh
		}
		set settings_live {
			endpoint https://api.paypal.com
			clientid AZ7lWRA4PVlqYr_ABUPncnmg0usDUdSuxr0CuQ4O7BuWddF1QWE07r_febuN
		  secret EJ5RtxBjL_X3EQaxGzBXdTJTAsRFTIUxqAXzci9tZ_sqrFNFn57DU1Ra4iPZ 
		}

		set :settings $settings_sandbox
	}

	:public method accessRules {} {
		#TODO this here but this could also be found in the DATABASE tables!
		# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
		# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
		# actions  
		return [dict create views { 
			view  { allow { users @ } }	
			subscription  { allow { users @ } }	
			finished { allow { users @ } }	
			cancel { allow { users @ } }
			createpayment { allow { users @ } }
			delete { allow { users @ } }
			admin { allow { users @ } }
		}   ]
	}

	:public method filters {} {
	
		return ""
	}

	:public method currentController {}	{
		return [string tolower Paypal];	
	}
	
	:public method subscription {{type ""}} {
		#CALC VALUE OR GET IT FROM SOMEWHERE ELSE..
		set status [list  "1 Month Full \$[my value 1]" 1 "6 Months Full \$[my value 2]" 2 "1 Year Full \$[my value 3]" 3 "1 Month Professional \$[my value 4]" 4 "6 Months Professional \$[my value 5]" 5 "1 Year Professional \$[my value 6]" 6]

		if {$type != ""} {
			return [lindex $status [lsearch $status $type]-1]
		}
		return $status
	}
	:public method value {type} {
		#1 month 6 months 1 year
		#1xFull  2xProfessional
		set value [list 7 1 37 2 70 3 27 4 147 5 270 6]
		return [lindex $value [lsearch $value $type]-1]
	}
	:public method actionIndex {} {
		#Using dataprovider and loading from database COMMENT?
		my render index model [Post new]
	}

	#:public method could have arguments as GET/POST 
	:public method actionView {} {
		set model [Paypal new]
		my render view model $model 
	}
	:public method actionSubscription {} {
		set model [Paypal new]
		my render view model $model 
	}
	:public method actionFinished {} {
		set model [Paypal new]

		if {[ns_conn :public method] == "GET"} {
			#Get token and payerid	
			set token [ns_queryget token]
			set payerid [ns_queryget payerid]
			#search either by token or by payerid..
		 if {[$model findByCond [list token $token]]} {
			
			set queryHeaders [ns_set create]
			set replyHeaders [ns_set create]
			ns_set update $queryHeaders Content-Type application/json
			ns_set update $queryHeaders Accept application/json
			ns_set update $queryHeaders Accept-Language en_US

			ns_set update $queryHeaders Authorization "Bearer [$model get access_token]"
			dict set B payer_id $payerid
			set B [tcl2json $B]

			set url [$model get execute_url] 
			set h [ns_ssl queue -:public method POST -headers $queryHeaders -body $B -timeout 10:0 $url ]
			ns_ssl wait -result R -headers $replyHeaders -status S  $h
			set paypal_response [json::json2dict $R]
		#	puts "paypal response: \n $paypal_response"	
			if {[dict exists $paypal_response name]} {
				set bhtml [bhtml new]
				set jumbotron [$bhtml jumbotron [dict get $paypal_response name]  [dict get $paypal_response message] ]
				my simpleRender $jumbotron

			} else {

				$model set state [dict get $paypal_response state] payment_at [getTimestamp]
				#from json to dict.. we have some problems with arrays..
				$model set related_resources [dict get [lrange [join [dict get $paypal_response transactions]] 0 end] related_resources]
				set payer_info [dict get $paypal_response payer payer_info]
				$model set e-mail [dict get $payer_info email]
				$model set first_name [dict get $payer_info first_name] last_name [dict get $payer_info last_name]

				$model save

				#Everything is OK here!
				#TODO add months to time! to subscription type!
			#	ns_puts "$token $payerid"
			#	ns_puts "for URL: $url <br> Result $R  <br> reply headers [ns_set array $replyHeaders] <br>Status $S <br> QueryHeaders [ns_set array $queryHeaders]<br>"
				if {[dict get $paypal_response state]=="approved"} { 
					set bhtml [bhtml new]
				set jumbotron [$bhtml jumbotron [msgcat::mc "Payment successful!" ] "The payment has succeeded, you can now start using your United Brain Power subscription."]

				my simpleRender $jumbotron

				}
			}
		 } else { ns_puts "Could not find this transaction!" }
		}
	}
	:public method actionCancel {} {
		set model [Paypal new]
		#my render view model $model 
		ns_puts "Cancelled!"
	}
	#TODO if PK same when creating new, view if not unique constraing..
	:public method actionCreatePayment {} {
		set model [Paypal new]
		#For when you want ajax validation..
		#$model nodjsRules $bhtml

		if {[ns_conn  method] == "POST"} {
			set queryattributes [$model getQueryAttributes POST ]
			set userid [ns_session get userid]
			puts "new payment"
	
			set price [my value [$model get subscription]]
			set subscription [my subscription [$model get subscription]]
			set description  "Payment for UnitedBrainPower $subscription "
			set clientcredentials  [dict get $settings clientid]:[dict get $settings secret]
		#	set clientcredentialsb [ns_base64encode $clientcredentials]
		#	NOT USING ns_base64encode because text gets wrapped.. requiring WRAPCHAR ""!!!
			set clientcredentialsb [base64::encode -wrapchar "" $clientcredentials]
			set queryHeaders [ns_set create]
			set replyHeaders [ns_set create]
	#	ns_set update $queryHeaders Content-Type application/json
		ns_set update $queryHeaders Content-Type application/x-www-form-urlencoded
			ns_set update $queryHeaders Accept application/json
			ns_set update $queryHeaders Accept-Language en_US

	#		ns_set update $queryHeaders Authorization "Basic [dict get $settings clientid]:[dict get $settings secret]]"
			ns_set update $queryHeaders Authorization "Basic $clientcredentialsb"

		#	set cd [list form-data; grant_type="$clientcredentials"]
		#	ns_set update $queryHeaders Content-Disposition "form-data; grant_type=\"authorization_code\""

 	
			set B "response_type=token&grant_type=client_credentials"
			#&code=$clientcredentials&client_id=[dict get $settings clientid]&client_secret=[dict get $settings secret]"
			#&redirect_uri=urn:ietf:wg:oauth:2.0:oob"
		#	set B ""
			set url [dict get $settings endpoint][dict get $urls access]
			set h [ns_ssl queue -method POST -headers $queryHeaders -body $B -timeout 10:0 $url ]
			ns_ssl wait -result R -headers $replyHeaders -status S  $h
			set paypal_response [json::json2dict $R]
			set access_token [dict get $paypal_response access_token]
		
		ns_puts "for URL: $url <br> Result $R  <br> headers [ns_set array $replyHeaders] <br>Status $S <br> QueryHeaders [ns_set array $queryHeaders]<br>"
		ns_puts "<br>$access_token and subscription [$model get subscription]<br><br>"
		
#Make Payment request
			set queryHeaders [ns_set create]
			set replyHeaders [ns_set create]
			ns_set update $queryHeaders Content-Type application/json
			ns_set update $queryHeaders Accept application/json
			ns_set update $queryHeaders Authorization "Bearer $access_token"

			set location [ns_conn location]
			set B ""
			dict set B transactions amount total $price
			dict set B transactions amount currency USD
			dict set B transactions description $description
			#Otherwise it won't work...
			dict set B transactions [list [dict get $B transactions]]
		dict set B  intent sale
			dict set B redirect_urls return_url $location[dict get $urls return_url]
			dict set B redirect_urls cancel_url $location[dict get $urls cancel_url]
			dict set B payer payment_method paypal
	#	puts "dictionary is $B"	
			set B [tcl2json $B]
	#		puts "B is $B"
			set url [dict get $settings endpoint][dict get $urls payment]
			set h [ns_ssl queue -method POST -headers $queryHeaders -body $B -timeout 10:0 $url ]
			ns_ssl wait -result R -headers $replyHeaders -status S  $h
		#TODO store in database...?
		#
			#if call successfull.. you canconfirm transaction creation 
			#you need to FINALIZE and CAPTURE the paypalpayment!
			#
			#
			set response [json::json2dict $R]

			$model set access_token $access_token user_id $userid
			$model set pay_id [dict get $response id]   creation_at [getTimestamp] payment_method paypal
			$model set description $description amount $price currency USD state [dict get $response state] 
			foreach d [dict get $response links] {
				if {[dict get $d rel] == "approval_url"} {
					set redirect_url [dict get $d href]
					puts "Redirecting to [dict get $d href]  PayPal"

					set s [ns_parsequery [lindex [split [dict get $d href] ?] 1]]

					$model set token [ns_set get $s token]		
				}
				if {[dict get $d rel] == "execute"} {
					$model set execute_url [dict get $d href]
				}
			}
			$model save
		if {[info exists redirect_url]} {	
					ns_returnredirect $redirect_url
		}
			#TODO If redirecting.. don't show text anymore
		ns_puts "for URL: $url <br> Result $R  <br> headers [ns_set array $replyHeaders] <br>Status $S <br> QueryHeaders [ns_set array $queryHeaders]<br>"
		ns_puts "<br>$access_token"
		ns_puts "<br><br> $response"
		} else {
			my redirect subscription	
		}
		#using ns_adp_parse AND ns_adp_include
		#my render create model $model
	}

	#ruff
	#or arguments id? to be included for actionUpdate	
	:public method actionUpdate {} {
		set id [ns_get id ]
		if {[set model [my loadModel $id]] ==0} { return }
		#For when you want ajax/javascript validation.. (ajax validation not working atm)
		#$model nodjsRules $bhtml
		set oldtags [$model getTags]
		$model setScenario update
		if {[ns_conn method] == "POST"} {

			set userid [ns_session get userid]
			set queryattributes [$model getQueryAttributes POST ]
			if {[$model get public_at] == ""} {
				$model set public_at [getTimestamp]
			}

			$model set update_at [getTimestamp]   update_user_id $userid
			set tags [$model get tags]
			$model unset tags

		$model setScenario updateall
			if {[$model save]} {
				$model updateTags $oldtags $tags
				my redirect view id $id
				return 1
			}
		}
	#	puts "Generating the update thingie.."
		#using ns_adp_parse AND ns_adp_include
		my render update model $model

	} 

	#or id as argument for this :public method
	:public method actionDelete {} {
		set id [ns_queryget id ]
		#TODO if not via POST..  give 400 error "invalid request"
		
	#TODO do intermediate step CONFIRMING the deletion..:D	
	#TODO or make undo button.. 
		#set model [my loadModel $id]
		if {[set model [my loadModel $id]] ==0} { return }

		set returnLoc [expr {[ns_queryexists returnUrl] ? "[ns_queryget returnUrl]" : "admin"}]
		if {[$model delete;]} {
			set infoalert [list -type success [mc "Successfully deleted column with id %d. TODO click here to UNDO" $id]]
			ns_session put infoalert $infoalert
		 #	my render $returnLoc infoalert $infoalert model $model
			my redirect $returnLoc model $model
		 }
	
	#TODO if AJAX request (triggered by deletion via admin grid view), we should not redirect the browser
		if {![ns_queryexists ajax]} {
			#my redirect $returnLoc model $model
		}
		#TODO show page that you've deleted this..
	}
	

	:public method actionAdmin {} {
		set model [Post new]
		#TODO unset any default values in model

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

#TODO find the best way to just stop execution without doing things like
#return -level 100 or ns_adp_return which gives error..
	:public method loadModel {id} {
		set model [Post new]
	
		#If id is empty (but query string contains data and it's a POST)
		#get the name of the classKey
		if {$id == ""} { 
			set id [ns_queryget [$model classKey id]]
			if {$id == ""} {  
				my notFound <br>[msgcat::mc "Please specify a valid id."]
			}
		}
		if {![string is double $id] && 0} {   
			my notFound <br>[msgcat::mc "Tried to search for id %d but just couldn't find it!" $id]
			return 0
		}
		$model setScenario "search"
		$model set id $id 
		if {[set validation [$model validate id]] != 0} { 	my notFound  [msgcat::mc "Not validating, sorry! %s" $validation]; return 0 }
		if {[$model findByPk -relations 1 $id] == 0} {
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



