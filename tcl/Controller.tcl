# ==  Controller   binds together model and views
#
# More info at http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014-2015 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014-2015 United Brain Power <info@unitedbrainpower.com>
#
# This program is distributed according to GPL 3 license <http://www.gnu.org/licenses/>.
#
nx::Class create Controller {
#TODO save controller name in variable?
	:variable currentController 
	:variable lang
	:variable urlLang 
	:variable layout

	:public method setLayout {layoutName} {
		set :layout $layoutName
	}

	:public method getLang {} {
		return ${:lang}
	}

	:public method getLanguage {} {
		set langs "English en Română ro  Nederlands nl"
		return [lindex $langs [lsearch $langs ${:lang} ]-1]
	}

	:public method render {{-controller ""} {-site ""} -- view args} {
		upvar pageinfo pageinfo
		set genbhtml 1
		set vars ""

		:renderArgs
		:generateBhtml

		if {$site ne ""} {
		 	append page  [ns_adp_parse   -file ./views/$site/$view.adp   {*}$vars ]
		} else {
			if {$controller == ""} { set controller	[my currentController] }
			append page  [ns_adp_parse   -file ../views/$controller/$view.adp   {*}$vars ]
		}

		:renderLayout

		ns_adp_close
	}

	:method renderArgs {} {
		foreach refVar {args vars genbhtml} { upvar $refVar $refVar }
		foreach {var value} $args {
			switch $var {
				bhtml { set genbhtml  0 }
			}
			upvar $var $var
			set $var $value
			lappend vars $$var
		}
	}

	:method generateBhtml {} {
		upvar 1 bhtml bhtml genbhtml genbhtml
		if {$genbhtml} {
			set bhtml [bhtml new ]
		}
		$bhtml Controller set [:currentController]
	}
	
	# Renders the $layout
	# First look in the current module views
	# then look in the general module views for generator
	# If all else fails, use layout.adp
	:method renderLayout {} {
		foreach refVar {page pageinfo bhtml} { upvar $refVar $refVar }
		set currentFile [file dir [lindex [ns_adp_info] 0]]
		set newLayoutFile [file join $currentFile ../views/${:layout}.adp] 

		if {[ns_filestat $newLayoutFile ]} { 
			set layoutLocation  $newLayoutFile 
		} elseif {[ns_filestat [ns_server pagedir]/views/${:layout}.adp ]} { 
			set layoutLocation [ns_server pagedir]/views/${:layout}.adp 
		} else {
			set layoutLocation [ns_server pagedir]/views/layout.adp   
		}

		ns_adp_include $layoutLocation -pageinfo $pageinfo -bhtml $bhtml  -controller [self]  $page
	}

	#TODO find someother way to end execution..
	:public method simpleRender  {page} {

		upvar pageinfo pageinfo
		dict set pageinfo breadcrumb  [list [mc Home]]
		set bhtml [bhtml new]
	
		:renderLayout 

		ns_adp_close
	}

	:public method errorPage  {heading body} {
		upvar pageinfo pageinfo
		dict set pageinfo breadcrumb  [list [mc Home] $heading]

		set bhtml [bhtml new]
		set page [$bhtml jumbotron $heading \n$body]

		:renderLayout

		ns_adp_close
	}	

	#good redirection to view.. 
	:public method redirect {{-controller ""} -- view args} {
		if {$controller == ""} { set controller	[my currentController] }
		ns_returnmoved [my getUrl -controller $controller $view $args] 
		ns_adp_close
		#return -level 3
	}

	:public method notFound {{extra ""}} {
		set n [ns_conn headers]
	#puts	"[ns_set array [ns_conn outputheaders]]"
		set bhtml [bhtml new]
		if {[string match *[ns_conn location]* [ns_set get $n Referer]]} {
			set link [ns_set get $n Referer]
		} else { set link [ns_conn location] }
		set goback [$bhtml link -simple 1 "[$bhtml fa fa-arrow-circle-left fa-2x] Or you can also go back from where you came from?" $link]

		set jumbotron [$bhtml jumbotron [msgcat::mc t:404notfound] [msgcat::mc p:404notfound  [concat $extra <p> $goback </p>]]] 
		#"Couldn't find the thing you were searching for. %s"
		my simpleRender $jumbotron
		$bhtml destroy
	}
	
	# overwrite when you need to return something else other than the index page
	#Returning to /index makes it simpler for URL generation since there can't be a controller without a view
	#or an empty view that gets the actionIndex
	:public method defaultAction {} {
			ns_returnmoved [ns_conn location]/[my currentController]/index
	}

	:public method defaultNotFound {} {
			my notFound
	}
	
	# First verify session language, if none is set look at the cookie 
	#	If the language from cookie, or session is different than from the
	#	language of the url, show the url in the language user is on
	#	We select the first preferred language of the browser 
	#	if accept-language doesn't exist we set the default configuration language
	#
	#TODO If first time on site and no cookie..ask which language he'd like?
	:public method lang {{_urlLang na}} {
		set lang [ns_session get lang [ns_getcookie lostmvc_lang $_urlLang]]

		set config [:loadConfigFile]


		if {$lang != $_urlLang && $_urlLang ne "na"} {
			set lang $_urlLang
		}

		if {$lang == "na"} {
			set nc [ns_conn headers]

			set configlang [dict get $config lang]
			set acceptLang [ns_set get $nc Accept-Language $configlang]
			set lang2 [split $acceptLang ,-]

			set lang [lindex $lang2 0]
			#TODO If first time on site and no cookie..ask which language he'd like?
		} 

		:setLangEverywhere $lang

		return $lang
	}

	:method setEncoding {} {
		set encoding utf-8
		if {$lang == "ro"} {
		#	set encoding iso8859-2
		}

		#Set encoding to output everything correctly
		#	ns_conn encoding $encoding
		#	encoding system $encoding
	}

	:method setLangEverywhere {lang} {
		msgcat::mclocale $lang

		set :urlLang $lang
		ns_session put urlLang $lang
		set :lang $lang

		msgcat::mcload [ns_pagepath]/lang
		#ns_session put urlLang [set :lang [set :urlLang $lang]]
	}

	:method loadConfigFile {} {
		set config	[ns_cache_eval -timeout 5 -expires 100 lostmvc config.[getConfigName]  { 
			set f [open	 [ns_pagepath]/tcl/config.tcl r]
			set filedata [read $f]
			close $f
			return $filedata
		}]
		return $config
	}

	# urlaction provides the functionality to redirect the url
	# to an action within the object of the controller.
	:public	method urlAction { } {

		set url [ns_conn url]
		set urlv [ns_conn urlv]
		set _urlLang [string tolower [lindex $urlv 0]]

		#Get current action
		if {[string length $_urlLang] == 2} {
			set action [string tolower [lindex $urlv 2]]
			set controller	[string totitle [lindex $urlv 1]]
		} else { 
			set action [string tolower [lindex $urlv 1]]
			set _urlLang na
		}
		
		my lang $_urlLang

		:redirectHttpToHttps
	
		:forceMultiLingual

		if {$action == ""} {
				if {![my preAction]} { return 0 }
				my defaultAction
				return 0
		}

		:determineAndRunUrlAction 

		my	postAction
	}

	:method determineAndRunUrlAction {} {
		upvar action action
		set actionmethods [:info lookup methods action*]
		if {[set loc [lsearch -nocase $actionmethods *$action]] != -1} {
		#Catching errors outside the scope, errors inside an view are shown anyway:)
			if {![my preAction $action]} { return 0 }
			try {
				my [lindex $actionmethods $loc] 
			} on error {result options } {
				if {[ns_adp_ctl detailerror]} {
					my errorPage [msgcat::mc  "Something went a little wrong.."] [msgcat::mc  "Error: %s Details: %s on line %d" \
					"<b>$result<b>" "<pre>[dict get $options -errorinfo]</pre><br>" [dict get $options -errorline] ]
				} else {
					#TODO log error somewhere!
					my errorPage [msgcat::mc  "A little error has occured"] [msgcat::mc  "Error: %s " \
					"<b>$result<b>"  ]
				ns_log Error "Error url [ns_conn url] $options $result "
				}

			}
		} else {
			my defaultNotFound 
		}
	}

	#Redirect simple HTTP to HTTPS
	# [lindex [split [ns_conn location] : ] 0] is replaced by ns_conn protocol
	:method redirectHttpToHttps {} {
		if {[ns_conn protocol] eq "http" && 0} {
			set query ""
			if {[ns_conn query] != ""} { set query ?[ns_conn query] }
			set redirecturl [ns_conn location]/${:lang}$url$query
			ns_returnredirect  $redirecturl 
			return ""
		}
	}

	:method forceMultiLingual {} {
		foreach refVar {urlv _urlLang url} { upvar $refVar $refVar }
	#TODO make setting forceMultilingual, if it's true then redirect to multilingual page:)
		set forceMultilingual 1
		if {$_urlLang eq "na" && $forceMultilingual && $urlv ne "index.adp"} {
			set query ""
			if {[ns_conn query] != ""} {
				set query ?[ns_conn query]
			}
			set redirecturl [ns_conn location]/${:lang}$url$query
		#	puts "Forcing multilingual redirect to $redirecturl url $url"
			ns_returnredirect $redirecturl 
		}
	}
	
	:public	method getUrlAction {} {
		#First is first is controller/view/action1/action2/action3/....
		#We have "different" actions 
		set url [ns_conn url]

		set actions  [ns_urldecode [lrange [join [split $url /]] 2 end]]
		return $actions
	}

	#	puts "Language [msgcat::mclocale]"
	#TODO before/preAction identifies filters and or access rules (verify if he may access the page.. etc)
	#TODO this could be done with ns_register_filter wheb method URL script ?args?
	#but let's do it 
	#verify if user has access
	#DO this here but this could also be found in the DATABASE
	:public method preAction {{action ""}} {

		set access [my accessRules]	
		#	set url [ns_conn url]
		#	set action [string tolower [lindex [join [split $url /]] 1]]
		if {$action == ""} { set action index }
		set ok 0
		set verifyrbac 0

		#Role Based Access Control
	# database = sql database
	# file = flat file (where is it located..?)
	# none/off/no = not enabled
		if {[dict exists $access rbac]} {
			set rbacvalue [string trim [dict get $access rbac]]
			#TODO differentiate between flat file and/or db.. first db
			switch $rbacvalue {
				database { set verifyrbac 1 }
				file { set verifyrbac 1}
				default { set verifyrbac 0 }
			}
		} 
		if {$verifyrbac} {
			set ok	[my verifyRoles $action]
		} else {
		#TODO allow/deny.. for now everything that's not in the list isn't allowed
		#TODO extendable selection from database..
			if {[dict exists $access views $action allow]} {
				set view [dict get $access views $action allow]

				if {[dict exists $view users]} {
					set users [dict get $view users]	
					foreach u $users {
						switch $u {
							* { set ok 1; break }
							@ { set ok  [my verifyAuthenticated] ; break }
							default { if {[set ok [my verifyUser $u]]} { break } }
						}
					}
				}
				#Roles are verified after the users, since it may well be possibile that 
				#the user isn't logged in:) 
				#If roles exist, reset OK to 0 (untill validated!)
				#TODO Roles from database, save them in session..? or cache them
				##TODO move them to different function..
				if {[dict exists $access views $action roles]} {
					set ok 0
					set roles [dict get $access views $action roles]	
					foreach r $roles {
					#verify if user has this role..
						if {[set ok [my verifyRole $r]]} { break }	
					}
					#Not authorized, show error for the moment
					#redirect to login later :)
				}
			}
		}
			#	puts "OK is $ok access is $access action $action get view [dict get $access views $action]"
		if {!$ok} { 
		#FOr login we just redirect him, if unauthorized or no rule exists.. or just the view has no settings.. tell him
			my errorPage [msgcat::mc t:unauthorized] [msgcat::mc  p:unauthorized]
			return 0
		}

		#Verify and apply FILTERS
		return 1	
	}

	:public	method postAction {} {
	#actions to do after the action finished..	
	}

	:public method urlKeys {url} {
		foreach {k v} [join [split $url /]] {
			upvar $k $k
			set $k $v
		}
	}

	#####################
	#	RBAC Roles
	#####################

	:public	method getModule {} {
		#Gets the module needed for RBAC
		set module ""
		#	puts "Role Controller is adp info [ns_adp_info]"
		set v [split [ns_adp_info] /]
		if {[set loc [lsearch -nocase $v modules]] != -1} {
			set module [string tolower [lindex $v $loc+1]]
		}
		return $module
	}

	:public method loadRoles {rbac {returnLogin 1}} {
		#Searching in the database for roles and verifying if they exist 
		#for the current rbac, or a "rbac" chosen by the user
		set r [RoleItem new]
		set access 0
		#Cache time 10 minutes.. not too much can change in that time for the roles and/or auth stuff..
		set time 600
		#Search for the "id" of the current module.controller.view 
		#	set action_id [dict get [$r search -where [list name $rbac ] "id" ] values]
		#puts "Roles $rbac"
		set data [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.action_id.$rbac  { 
			$r search -where [list name $rbac ] "id"  
		}]
		set guestid [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.guestid  { 
			dict get  [$r search -where [list name "guest" ] "id" ] values
		}]
		set authid [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.authid  { 
			dict get  [$r search -where [list name "authenticated" ] "id" ] values
		}]
		#easier to do $r findByCond [list name "authenticated]
		#$r get id
		#return 1
		if {$data == ""} { 
		#TODO what happens when nothing exists in DB for this view?
		#Go along and see if other accessRules exist? or forbid the client?
			puts "/!\\ WARNING /!\\ : No RBAC data found for \"$rbac\"!"
			#Allow client
			return 0
		} else {
			set action_id [dict get $data values]
		#	puts "LoadRoles  $rbac data $action_id"
		}

		#TODO CACHE
		#Search all the possible descendants/parents of this current child
		# within the RBAC
		set select_recursive_rbac		{
			WITH RECURSIVE nodes(parent_id,parent_name,child_id,child_name,path,depth) AS (
			SELECT ric.parent_id, r1.name,
			ric.child_id,r2.name,
			ARRAY[ric.child_id],1
			FROM role_item_child AS ric, role_item AS r1, role_item AS r2
			WHERE 
			ric.child_id=:action_id AND
			r1.id=ric.parent_id AND r2.id= ric.child_id
			UNION ALL
			SELECT ric.parent_id, r1.name,
			ric.child_id,r2.name,
			path || ric.child_id, nd.depth+1
			FROM role_item_child AS ric, role_item AS r1, role_item AS r2, 
			nodes AS nd
			WHERE 
			ric.child_id = nd.parent_id AND
			r1.id=ric.parent_id AND r2.id= ric.child_id 
			) SELECT * from nodes;}
		dict set pr_stmt action_id $action_id 
		
		#Contains ALL parent/children history
		#even authenticated / guest ones!
		set cache [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.recursive.$action_id  { 
			lappend return [dbi_rows -db [$r db get] -columns reccolumns -bind $pr_stmt $select_recursive_rbac ]
			lappend return $reccolumns
			return $return 
		}]
			lassign  $cache  recvalues reccolumns
					
			
		unset pr_stmt

		#Select all the role assignments an user has
		#
		if {[ns_session contains userid]} {
			set userid [ns_session get userid] 
		#	dict set pr_stmt action_id $authid 

			set sql_select "
			SELECT ri.id,ri.name
			FROM role_assignment ra, role_item ri
			WHERE ra.item_id=ri.id 
			AND user_id=:user_id"
			dict set pr_stmt user_id $userid 
			set uservalues  [dbi_rows -db [$r db get] -columns usercolumns -bind $pr_stmt $sql_select ]

			#Verify roles for logged in user
			if {[lsearch $uservalues $action_id] != -1} { incr access 1 }
			foreach $reccolumns $recvalues {
				if {[lsearch $uservalues $parent_id] != -1} { incr access 1 }
			}

			#View if user has "superadmin" powers, give him 1

			#	if {[lsearch $uservalues "superadmin"] != -1} { incr access 1 ; puts "Whoa, we've got a superadmin! with values \n $uservalues\n" }
			
			 set usertype authenticated
		} else {
			set usertype guest

		#	dict set pr_stmt action_id $guestid 
		}
		#Get RBAC for authenticated and/or guests.. and verify it	
		#set authguestvalues [dbi_rows -db [$r db get]  -bind $pr_stmt $select_recursive_rbac ]
		foreach $reccolumns $recvalues {
			if {$parent_name == $usertype} { incr access 1 ; break}
		}	

		
		#If usertype = guest and access = 0
		#Redirect to login page
		if {$usertype =="guest" && $access == 0} {
			if {$returnLogin} {
				my returnLogin
			}
		} 
		#if usertype = authenticated and access = 0
		# show you're not allowed..
		# else if access => 1  allowed
		return $access
	}

	#	Verify All Roles
	:public method verifyRoles {action} {
		set module [my getModule]	
		set controller [my currentController]
		if {$module != ""} {
			lappend rbac $module 
		}
		lappend rbac $controller $action
		set rbac [join $rbac .]

		set roles [my loadRoles $rbac]
		return $roles
		if {$roles == 0} {

		}
	}


	:public method verifyRole {rolename} {
	#Verify the role, while doing that see if the user is logged in..
	#if not then redirect to the login page
	# first verifies if role is function, runs it.. then continues
		if {[ns_session contains userid]} {

		#	puts "hey there $rolename"
		#Verify first if there exists a function with this name
		#set function role[string totitle $rolename]
		set function $rolename
			if {[lsearch [: info lookup methods ] $function ] != -1} {
			#if {[lsearch [info class methods [self class]] $function ] != -1} 
				return [my $function]
			} 
			return [my loadRoles $rolename]
		} else {

			return [my returnLogin]	
		}
	}

	:public	method hasRole {rolename} {
		return [my loadRoles $rolename 0]
	}

	:public method returnLogin {} {
		#Save the page the user was trying to view
		#If he logs in afterwards return to his returnto variable
		set returnto [ns_conn url]
		if {[string length [ns_conn query]]} {
			append returnto ?[ns_conn query]
		}
		ns_session put returnto $returnto
		ns_session put sessionexpired 1
		#When redirecting to login, make it secure
		set location [ns_conn location]
		set location [join [lreplace [split $location : ] 0 0 https] :]
		ns_returnredirect $location/${:lang}/user/login
		return 0
	}

	:public method verifyUser {user} {
		if {[my verifyAuthenticated]} {
			if {[ns_session get username] == $user} { 
				return 1
			}
		}
		#	my errorPage "You aren't authorized to view this page" "Sorry, you can't view this page. Not authorized. "
		return 0
	}

	:public method verifyAuthenticated {{-redirnotlogged ""} {-redirlogged ""} } {
		#	puts "Hey verify auth  what's up for [ns_session get username]"
		if {[ns_session contains userid]} {
		#Update the session with every verification..
			if {$redirlogged != "" } {
				ns_returnredirect $redirlogged
			}

			ns_session get userid
			return 1
		} else {
			my returnLogin
			return 0
		}
	}

	:public method verifyAuth {} {
		if {[ns_session contains userid]} {
			return 1
		} else {
			return 0
		}
	}

	#This method verifies if the ID / username requested is himself
	#Only allow the user to view/edit/update where he uses his own ID
	:public method verifySelf {who {what userid}} {

		if {[ns_session contains $what]} {
			if {$who == [ns_session get $what]} {
				return 1
			}
		}
		return 0
	}
	
	#isSelf rule method..
	:public method isSelf {} {
		if {[ns_session contains userid]} {
			if {[ns_get id] == [ns_session get userid]} {
				return 1
			}
		}
		return 0
	}

	:public method getUrl {{-controller ""} {-c ""}  {-url 1} {-lang ""} -- action {query ""}} {
		if {$c ne ""} { set controller $c }

		if {$controller == ""} {
			set controller [my currentController] 
		}

		#	if {$text == ""} {
		#		set text [mc $action]
			#	}
			#set url [$bhtml a $text $controller/$action]
			#	set url /$controller/$action	
	

		set link /$controller/$action[ns_queryencode {*}$query]
		if {$controller == false} {
			set link /$action[ns_queryencode {*}$query]
		} 

		if {${:urlLang} ne "na"} { 
			if {$lang eq ""} {
				set lang ${:urlLang}
			}
			set link /${lang}$link
		}

		return $link	
	}
   #//Admin role!
   if {0} {
   method admin {} {
   #Example how to set advanced roles..
	   if {[ns_session get username]=="lostone"} {
		   return 1
	   } else { return  0}
   }	
   }
   #todo special function 
   ##TODO special font.. and other types..
   :public method actionCaptcha {} {
	   my captcha "" 
   }

   :method captcha {type} {
	   set font [ns_server pagedir]/fonts/FreeSans.ttf
	   #set font [file dirname [web::config script]]/gamesys/FreeSans.ttf
	   set width 160 ; set height 70 ; set font_size 25
	   set img [GD create lol $width $height]

	   set background [$img allocate_color [rnd 200 255]  [rnd 200 255]  [rnd 200 255]  ] ; #background color

	   #Lines
	   set rl [rnd 0 200] ; set bl [rnd 0 200] ; set gl [rnd 0 200]
	   set lineColor [$img allocate_color  100 200 220]
	   for {set i 0} {$i<0} {incr i} {
	   #set rl [rnd 0 200] ; set bl [rnd 0 200] ; set gl [rnd 0 200]
	   #set lineColor [$img allocate_color $rl $bl $gl];# 100 200 220]

		   set x1 [rnd 0 $width] ; set x2 [rnd 0 $width] ; set y1 [rnd 0 $height]  ;set y2 [rnd 0 $height]
		   $img line  $x1 $y1 $x2 $y2 $lineColor 
	   }
	   set minwidth 0
	   for {set var 0} {$var < 5} {incr var} {
	   #	set newWidth [expr {$width/2+$minwidth}]
	   #	set newHeight [expr {$height*0.8}]
	   #set x1 [rnd $minwidth $newWidth] ; set x2 [rnd 0 $width] ; set y1 [rnd 0 $newHeight]  ;set y2 [rnd 0 $height]
	   #
		   set x1 [rnd 0 $width] ; set x2 [rnd 0 $width] ; set y1 [rnd 0 $height]  ;set y2 [rnd 0 $height]
		   set dheight [rnd 10 50] ; set dwidth [rnd 10 50]

		   set lineColor  [$img allocate_color  [rnd 50 255]  [rnd 50 255]  [rnd 50 255] ]
		   $img set_anti_aliased $lineColor
		   set what [rnd 0 1]

		   $img  filled_ellipse  $x1 $y1 $dheight $dwidth $lineColor	
		   if {$what ==1} {

		   #	$img  filled_ellipse  $x1 $y1 $dheight $dwidth $lineColor	
		   } elseif {$what == 0} {

		   #	$img  filled_rectangle  $x1 $y1 $dheight $dwidth $lineColor	
		   #$img  filled_ellipse  $x1 $y1 $dheight $dwidth $lineColor	

		   #$img set_thickness [rnd 3 10]
		   #$img line  $x1 $y1 $x2 $y2 $lineColor 

		   #	incr minwidth 20	
		   }
		   #	$img deallocate_color $lineColor
	   }

	   #Text
	   set r [rnd 0 200] ; set b [rnd 0 200] ; set g [rnd 0 200]
	   #set textColor [$img allocate_color $r $b $g]
	   #set textColor [$img allocate_color 255 255 255]
	   set textColor [$img allocate_color 0 0 0]

	   $img set_anti_aliased $textColor
	   if {$type == "calc"} {	set text [humanTest] } else { 
		   set textSession [generateCode 5 2] 
		   set text [split $textSession ""]
		 #  set text $textSession
		   #	Session::cset humanTestAnswer $text
		   #		Session::commit
	   }

	   ns_session put humanTest $textSession
	   #$img text $textColor $font $font_size [rnd -10 0] [expr {round($width*0.5 - ([string length $text]*$font_size*0.7)/2)} ]   [expr {round($height/2 + $font_size/2)} ]   $text
	   $img text $textColor $font $font_size [rndDouble -0.2 0.2] [expr {round($width*0.5 - ([string length $text]*$font_size*0.6)/2)} ]   [expr {round($height/2 + $font_size/2)} ]   $text

	   # set HTTP header to "image/jpeg" instead of "text/html"
	   #  web::response -set Content-Type image/jpeg

	   #	set file [open $image w]
	   # because we return a img, change to binary again
	   #   fconfigure $file -translation binary -encoding binary

	   # output
	   #  puts $file [$img jpeg_data 90]
	   ns_return -binary 200 image/jpeg [$img jpeg_data 90]
   }

	:public method actionDelete {} {
		set id [ns_queryget id ]
		#TODO if not via POST..  give 400 error "invalid request"
		
	#TODO do intermediate step CONFIRMING the deletion..:D	
	#TODO or make undo button.. 
		#set model [my loadModel $id]
		if {[set model [my loadModel $id]] ==0} { return }

		set returnLoc [expr {[ns_queryexists returnUrl] ? "[ns_queryget returnUrl]" : "admin"}]
		if {[set rid [$model delete;]]} {
			set bhtml [bhtml new]
			set link [$bhtml link -controller [my currentController] [mc "Click here to restore it."] restore [list id $rid]]
			set infoalert [list -type success [concat [mc "Successfully deleted item with id  %d." $id] $link] ]
			ns_session put infoalert $infoalert
		 #	my render $returnLoc infoalert $infoalert model $model
			my redirect $returnLoc
		 }
	
	#TODO if AJAX request (triggered by deletion via admin grid view), we should not redirect the browser
		if {![ns_queryexists ajax]} {
			#my redirect $returnLoc model $model
		}
		#TODO show page that you've deleted this..
	}

	:public method actionRestore {} {
		set model [Post new]
		set id [ns_queryget id ]

		if {[$model restore $id]} {

			set infoalert [list -type success [mc "This item has been restored from the Recycle Bin." ]  ]
			ns_session put infoalert $infoalert
			#my render view model $model
			my render index model $model infoalert $infoalert 
		} else {
			set infoalert [list -type danger [mc "Could not restore item from Recycle Bin with id %d. 
		Either the data has been fully deleted or there is no such data deleted." $id ][$model errors]  ]
			ns_session put infoalert $infoalert
			my render index model $model infoalert $infoalert	
		}
	}
}
	
