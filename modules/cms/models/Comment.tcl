#Model
nx::Class create Comment -superclass Model {

	:method init {} {
		set :attributes { 
			table blog_comment
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				reply_to {
					unsafe {
						on all

					}

				}
				post_id {
				unsafe {
						on all

					}
				}
				comment {
					validation {
						string {
							on all

						}

					}

				}
				creation_at {
					unsafe {
						on all

					}


				}
				user_id {
					unsafe {
						on all

					}

				}
				status {
					unsafe {
						on all

					}
				}

			}
			relations {
				post {column post_id fk_table blog_post fk_column id fk_value title}
				reply {column reply_to fk_table blog_comment fk_column id fk_value id}
				user {column user_id fk_table users fk_column id fk_value username}

			}

 }  
		set :alias { 
			id Id
			reply_to {Reply to}
			post_id {Post id}
			comment Comment
			creation_at {Creation at}
			user_id {User id}
			status Status

 }
		next 
	}

:public	method genStatus {status} {
		set bhtml [my bhtml]
		set return [my status $status]<br>
		append return " " [$bhtml a -class doAjaxTask -fa [list fa-check fa-lg] [mc Approve] approve[ns_queryencode id [my get id] approve 1]]
		append return " " [$bhtml a -class doAjaxTask -fa [list fa-ban fa-lg] [mc Ban] approve[ns_queryencode id [my get id] approve 2]]
		return $return
	}

:public	method status {{st ""}} {
		#Verify if the column is within language
	#	if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set status [list "Waiting approval" 0 "Approved" 1 "Blocked" 2 ]
		if {$st != ""} {
			return [lindex $status [lsearch $status $st]-1]
		}
		return $status
	}

:public	method genComments {post_id} {
		set postcomments ""
		set c [SQLCriteria new -model [self]]
		$c add post_id $post_id
		$c add status 1
		# TODO reply self referencing relation fix it..
		set comments [my search -criteria $c -relations 1   [list id  post comment creation_at user status ]]
		if {$comments  == ""} { return "" }
		set bhtml [ bhtml new]
		foreach [dict get $comments columns] [dict get $comments values] {
			append postcomments  [$bhtml tag -htmlOptions [list name comment-$id] a]
			append postcomments [$bhtml media "$user [$bhtml tag small [howlongago [clock scan $creation_at]]]" $comment]	
		}
		return [$bhtml tag p $postcomments]
		#	return [$bhtml media "Andrei's comment" "Viata e faina la tzara langa Adriana!"][$bhtml media "Andrei's comment" "Cea mai frumoasa experienta langa ea!"] 
	#	return [$bhtml table [dict get $comments columns] [dict get $comments values]]
	}


}

