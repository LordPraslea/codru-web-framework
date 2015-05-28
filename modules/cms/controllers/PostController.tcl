##########################################
# Controller Generation
##########################################

nx::Class create PostController  -superclass Controller {
#variable layout
	:variable pageinfo

	:method init {} {
	#set attributes { %s }  
	#next $attributes $alias
		set :layout blog
		#my	setLayout layout
		dict set :pageinfo author "United Brain Power"
	}

	:public method accessRules {} {
	#TODO this here but this could also be found in the DATABASE tables!
	# controllers <controller> [allow|deny]  roles [list roles]  users ["username"|*=al|@=logged in] 
	# views	<view> [allow||deny]  roles [list roles]  users ["username"|*=al|@=logged in]
	# actions  
		return [dict create views { 
			view  { allow { users * } }	
			tag  { allow { users * } }	
			author  { allow { users * } }	
			index { allow { users * } }	
			update { allow { users @ } }
			create { allow { users @ } }
			delete { allow { users @ } }
			restore { allow { users @ } }
			admin { allow { users @ } }
		} rbac database   ]
	}

	:public method filters {} {

		return ""
	}

	:public method currentController {}	{
		return [string tolower Post];	
	}

	:public method actionIndex {} {
	#Using dataprovider and loading from database COMMENT?
		my render index model [Post new]
	}

	#:public method could have arguments as GET/POST 
	:public method actionView {} {
		set id [ns_queryget id 1 ]

		if {[set model [my loadModel $id]] ==0} { return }

		set commentmodel [my addComment $model]
		my render view model $model commentmodel $commentmodel	
		#my render view model $model 
	}

	#TODO if PK same when creating new, view if not unique constraing..
	:public method actionCreate {} {
		set model [Post new]

		#$model nodjsRules $bhtml
		if {[ns_conn  method] == "POST"} {
			$model setScenario create

			set tags [:handleCreateUpdate $model]
			if {[$model save]} {
				$model addTags $tags
				#Redirect stops all other things from going on..
				my redirect  [$model get slug]
				return 1
			}

		}
		my render create model $model
	}


	:public method actionUpdate {} {
		set id [ns_get id ]
		if {[set model [my loadModel $id]] ==0} { return }

		set oldtags [$model getTags]
		$model setScenario update
		if {[ns_conn method] == "POST"} {

			set tags [:handleCreateUpdate $model]

			$model setScenario updateall
			if {[$model save]} {
				$model updateTags $oldtags $tags
				my redirect  [$model get slug]
				return 1
			}
		}
		my render update model $model
	} 

	:method handleCreateUpdate {model} {
		set queryattributes [$model getQueryAttributes POST ]
		set userid [ns_session get userid]
		set cms [ns_queryget blog_post_cms]

		if {[$model get public_at] == ""} {
			$model set public_at [getTimestamp]
		}
		if {[$model get creation_at] == ""} {
			$model set creation_at [getTimestamp] author_id $userid
		}

		$model set update_at [getTimestamp]  update_user_id $userid

		set tags [$model get tags]
		$model unset tags

		set data [ns_striphtml [$model get post]]
		#Average word length 5 at 200 words per minute..
		$model set reading_time [expr {round([string length $data]/5./200)}]

		$model setScenario add
		return $tags
	}
	if {0} {
		#or id as argument for this :public method
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


	:public method actionAdmin {} {
		set model [Post new]
		#TODO unset any default values in model

		if {[ns_conn  method] == "POST"} {
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


	#TODO Show all posts, authors etc for this tag!
	:public method actionTag {} {
		set model [Post new]
		set actions [my getUrlAction]
		if {$actions == ""} { set actions [ns_urldecode [ns_get tag]]}
		set tag [Tags new]
		if {[$tag findByCond  [list tag $actions]]} {

			dict set pr_stmt tag_id [$tag get id]
			set sql_select "SELECT post_id FROM blog_tags  WHERE tag_id=:tag_id "

			set values  [dbi_rows -db [$model db get] -columns columns -bind $pr_stmt $sql_select ]
			#	ns_puts "tag $actions tagid [$tag get id] and $values"
			lappend where [list -cond IN id  $values]

		} else {

			lappend where [list id  0]
		}
		#TODO different model..?

		my render index model $model where $where title "Blog posts for Tag: $actions"
	}

	:public method actionAuthor {} {
		set model [Post new]
		set actions [my getUrlAction]
		if {$actions == ""} { set actions [ns_urldecode [ns_get author]]}
		set u [User new]
		if {[$u findByCond  [list username $actions]]} {
			lappend where [list author_id  [$u get id]]
		} else {
			lappend where [list id  0]
		}

		my render index model $model where $where title "Blog posts by Author: $actions"
	}



	:public method addComment {model} {

		set cm [Comment new]
		if {[ns_conn  method] == "POST" && [ns_queryexists iscomment] && [my verifyAuth]} { 
		##	puts "Ok environment to add comment! "
			$cm getQueryAttributes POST
			$cm set creation_at [getTimestamp] post_id [$model get id]
			$cm set user_id [ns_session get userid] status 0
			#reply_to
			#comment
			if {[$cm save]} {
			#	TODO RETURN	"Your comment has been saved, it is due to review by a moderator."
			}
		}
		return $cm
	}

	#Default action for blog is to search the slug or id..
	#If nothing found by slug or id..  #show first page of blog..
	:public method defaultNotFound {} {
		set url [ns_conn url]
		set urlv [ns_conn urlv]
		set index 1
		#Always use urlv it's already split)
		if {${:urlLang} ne "na" && [string length [lindex $urlv 0]] == 2 } { incr index 1 }
		set action [string tolower [lindex [join [split $url /]] $index]]
		set model [Post new]
		set criteria [SQLCriteria new -model $model ]

		if {![string is integer $action]} {
			$criteria add slug $action
		} else {
			$criteria add id $action
		}
		if {[$model findByCond -relations 1 $criteria]} {
			if {[$model get cms]} {
				my render cmsview model $model 
			} else {
				set commentmodel [my addComment $model]
				my render view model $model commentmodel $commentmodel	
			}
		} else {
			my notFound	
			#my redirect index
		}
	}

	#Not working yet
	:public method actionPrint {} {
		variable layout
		set layout print
		my	defaultNotFound
	}

}



