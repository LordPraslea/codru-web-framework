##########################################
# Controller Generation
##########################################

nx::Class create SiteController -superclass Controller {
	#variable layout
	:variable pageinfo

	:method init {} {
		#set attributes { %s }  
		#next $attributes $alias
		set :layout layout
		#my	setLayout layout
		dict set pageinfo author ""
		next
	}

	:public method accessRules {} {
		#TODO this here but this could also be found in the DATABASE tables!
		# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
		# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
		# actions  
		return [dict create views { 
			index  { allow { users * } }	
			test  { allow { users * } }	
			contact  { allow { users * } }	
		} rbac none   ]
	}

	:public method filters {} {
	
		return ""
	}

	:public method currentController {}	{
		return [string tolower Site];	
	}
	
	:public method actionIndex {} {
		set lang [my getLang]

		if {![file exists [ns_pagepath]/modules/cms/views/site/index-$lang.adp]} {
		#Or default config language!
			set lang en
		}
		#ns_adp_include ./views/site/index-$lang.adp
		#set pageinfo ""
		#$c setLayout layout
		#$c render -site site index-$lang

		my render index-$lang nocontent 1

	}

	:public method actionTest {} {


		my render test 

	}

	:public method actionContact {} {
	#	foreach k {name email message captcha}  { set $k [ns_queryget $k ""]}
		set model [ContactUs new] 
		if {[ns_conn  method] == "POST"} {
		
			set queryattributes [$model getQueryAttributes POST ]

			$model set sent_at [getTimestampTz] ip [ns_conn peeraddr] 
			if {[$model save]} {
					set infoalert [list -type success [mc "Your message has been saved. We'll contact you in the shortest time possible."]]
					set msg "[$model get name]  [$model get email] contacted you at [$model get sent_at] :<br>
						[$model get message]	
					"
					send_mail info@andreiclinciu.net "UnitedBrainPower: You have a message from [$model get name]" $msg 
					my render contact model $model infoalert $infoalert
					return 1
			}
		}


		my render contact model $model

	}

	:public method defaultNotFound {} {
		set pc [PostController new]
		$pc lang [my getLang]
		$pc defaultNotFound
		$pc setLayout blog
		#ns_puts "Yeah, bloggin for ya!"
	}

	
	:public method performAjaxValidation {model} {
		if {0} {
			if(isset($_POST['ajax']) && $_POST['ajax']==='site-form')
			{
				echo CActiveForm::validate($model);
				Yii::app()->end();
			}
		}
	}
		
}



