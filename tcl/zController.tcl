# ==  Controller   binds together model and views
#
# More info at http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014-2015 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014-2015 United Brain Power <info@unitedbrainpower.com>
#
# This program is distributed according to GPL 3 license <http://www.gnu.org/licenses/>.
#
nx::Class create Controller -mixin [list LanguageController ImageGalleryController] -superclass [list AuthorizationRbac] {
#TODO save controller name in variable?
	:variable currentController 
	:variable layout

	:public method setLayout {layoutName} {
		set :layout $layoutName
	}


	:public method render {{-controller ""} {-site ""} -- view args} {
		:upvar pageinfo pageinfo
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
		foreach refVar {args vars genbhtml} { :upvar $refVar $refVar }
		foreach {var value} $args {
			switch $var {
				bhtml { set genbhtml  0 }
			}
			:upvar $var $var
			set $var $value
			lappend vars $$var
		}
	}

	:method generateBhtml {} {
		:upvar 1 bhtml bhtml genbhtml genbhtml
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
		foreach refVar {page pageinfo bhtml} { :upvar $refVar $refVar }
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

		:upvar pageinfo pageinfo
		dict set pageinfo breadcrumb  [list [mc Home]]
		set bhtml [bhtml new]
	
		:renderLayout 

		ns_adp_close
	}

	:public method errorPage  {heading body} {
		:upvar pageinfo pageinfo
		dict set pageinfo breadcrumb  [list [mc Home] $heading]

		set bhtml [bhtml new]
		set page [$bhtml jumbotron $heading \n$body]


		if {![ns_queryget ajaxRequest 0]} {
			:renderLayout
		} else {
			set data [dict create json strict  location overwrite modal new title $heading  data $page ]
			ns_puts [tcl2json $data]
		}

		ns_adp_close
	}	

	#good redirection to view.. 
	:public method redirect {{-controller ""} -- view args} {
		if {$controller == ""} { set controller	[my currentController] }
		ns_returnmoved [my getUrl -controller $controller $view $args] 
		ns_adp_close
		#return -level 3
	}

	:method notFound {{extra ""}} {
		set n [ns_conn headers]
	#puts	"[ns_set array [ns_conn outputheaders]]"
		set bhtml [bhtml new]
		if {[string match *[ns_conn location]* [ns_set get $n Referer]]} {
			set link [ns_set get $n Referer]
		} else { set link [ns_conn location] }
		set goback [$bhtml link -simple 1 "[$bhtml fa fa-arrow-circle-left fa-2x] Or you can also go back from where you came from?" $link]
				set rnd [rnd 1 5]	
			set hamster [$bhtml img /img/404/hamster404_${rnd}.jpg]

		set jumbotron [$bhtml jumbotron [msgcat::mc t:404notfound] "$hamster [msgcat::mc p:404notfound  [concat $extra <p> $goback </p>]]"] 
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
	

	:method setEncoding {} {
		set encoding utf-8
		if {$lang == "ro"} {
		#	set encoding iso8859-2
		}

		#Set encoding to output everything correctly
		#	ns_conn encoding $encoding
		#	encoding system $encoding
	}



	:public method loadConfigFile {} {
		set config	[ns_cache_eval -timeout 5 -expires 100 lostmvc config.[getConfigName]  { 
			ns_adp_parse	-file  [ns_pagepath]/tcl/config.adp 
			return $config
		}]
		return $config
	}

	# urlaction provides the functionality to redirect the url
	# to an action within the object of the controller.
	:public	method urlAction { } {
		set url [ns_conn url]
		set urlv [ns_conn urlv]
		set _urlLang [string tolower [lindex $urlv 0]]

		#Get current action, based on locale (en or en_US)
		if {[string length $_urlLang] == 2 || [string length $_urlLang] == 5} {
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
		:upvar action action
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
				#TODO encode error and show it encoded.. so the user sends it to you 
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
	
	:public	method getUrlAction {} {
		set url [ns_conn urlv]
		set index 2
		if {[string length ${:urlLang}] in "2 5"} {
			incr index
		}
		set actions  [ns_urldecode [lrange $url $index end]]
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

		:preActionRbacType
		:preActionVerifyAccess

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
			:upvar $k $k
			set $k $v
		}
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
		return 0
	}

	:public method verifyAuthenticated {{-redirnotlogged ""} {-redirlogged ""} } {
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

	#TODO make global variable in controller 
	#currentView and verify against that one
	#Used to know which link to use
	:public method isActiveLink {link} {
		set url [ns_conn url]
		set urlv [ns_conn urlv]

		if {[string match -nocase *$link* $url]} {
			return 1
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

   #//Admin role example!
   if {0} {
   method admin {} {
   #Example how to set advanced roles..
	   if {[ns_session get username]=="lostone"} {
		   return 1
	   } else { return  0}
   }	
   }

   #TODO in different class?
   :public method actionCaptcha {} {
	   my captcha "" 
   }

   :method captcha {type} {
	   set font [ns_server pagedir]/fonts/FreeSans.ttf
	   #set font [file dirname [web::config script]]/gamesys/FreeSans.ttf
	   set width 160 ; set height 70 ; set font_size 25
	   set img [GD create lol $width $height]

	   set background [$img allocate_color [rnd 200 255]  [rnd 200 255]  [rnd 200 255]  ] ; #background color

		:drawCaptchaImage $img

	   #Text
	   set r [rnd 0 200] ; set b [rnd 0 200] ; set g [rnd 0 200]
	   set textColor [$img allocate_color 0 0 0]

	   $img set_anti_aliased $textColor
	   if {$type == "calc"} {	set text [humanTest] } else { 
		   set textSession [generateCode 5 2] 
		   set text [split $textSession ""]
	   }

	   ns_session put humanTest $textSession
	   $img text $textColor $font $font_size [rndDouble -0.2 0.2] [expr {round($width*0.5 - ([string length $text]*$font_size*0.6)/2)} ]   [expr {round($height/2 + $font_size/2)} ]   $text

	   ns_return -binary 200 image/jpeg [$img jpeg_data 90]
   }
   
   :method drawCaptchaImage { img } {
	   foreach refVar {width height font_size l} { :upvar $refVar $refVar }
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

		   $img  filled_ellipse  $x1 $y1 $dheight $dwidth $lineColor	
		   #	$img deallocate_color $lineColor
	   }
   }

	#General  Delete method 
	# We don't really delete the field, we just save it in the database
	:public method actionDelete {} {
		set id [ns_queryget id ]
		#TODO if not via POST..  give 400 error "invalid request"
		
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
	
	#We restore the data from the database (if accidentally deleted)
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

	:public method getDataFromTemplate {templateFileName templateHolder  } {
		set file [open [ns_server pagedir]/$templateFileName r]
		set template_data [read $file]
		set template_data [string map $templateHolder $template_data ]
		close $file
		return $template_data
	}

	#############
	#LoadModel Subfunctions!
	#############

	:method loadModelEmptyId {} {
	   foreach refVar {id returnFunction model} { :upvar $refVar $refVar }

		if {$id == ""} { 
			set id [ns_queryget [$model classKey id]]
			if {$id == ""} { 
				set msg		[msgcat::mc "Please specify a valid id."]
				$returnFunction $msg
				return -level 2 0
			}
		}
	}

	:method loadModelIsDouble {} {
	   foreach refVar {returnFunction id} { :upvar $refVar $refVar }

		if {![string is double $id]} {   
			set msg [msgcat::mc "Tried to search for id %s but just couldn't find it!" $id]
			$returnFunction $msg
			return -level 2  0
		}
	}

	:method loadModelValidateId	{} {
	   foreach refVar {model returnFunction} { :upvar $refVar $refVar }

		if {[set validation [$model validate id]] != 0} { 
			set msg [msgcat::mc "Not validating, sorry! %s" $validation]
			$returnFunction $msg
			return -level 2 0 
		}
	}
	:method loadModelFindByPk {} {
	   foreach refVar {model returnFunction id} { :upvar $refVar $refVar }

		if {[$model findByPk -relations 1 $id] == 0} {
			set msg [msgcat::mc "Tried to search for id %s but just couldn't find it!" $id]
			$returnFunction $msg
			return -level 2 0
		} else {  	return -level 2 $model; }
	}

	:method loadModelFindByCond {criteria} {
	   foreach refVar {model returnFunction id} { :upvar $refVar $refVar }

		if {[$model findByCond -relations 1 $criteria] == 0} {
			set msg [msgcat::mc "The id ( %s ) you are searching for doesn't exist!" $id]
			$returnFunction $msg
			return -level 2 0
		} else {  	return -level 2 $model; }
	}

	:method returnNotFound {msg} {
		:notFound <br>$msg
	}

	:method returnAjaxNotFound {msg} {
		dict set response error $msg
		ns_puts [tcl2json $response]
	}


}
	
