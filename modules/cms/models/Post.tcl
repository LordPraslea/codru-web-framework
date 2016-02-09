#Model
nx::Class create Post -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table blog_post
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				title {
					validation {
						required {
							on all

						}

					}

				}
				slug {
					validation {
						required {
							on all

						}

					}

				}
				post {
					validation {
						required {
							on all
						}

					}

				}
				creation_at {
					unsafe { on all }

				}
				author_id {
		
					unsafe { on all }
	
				}
				update_at {
					unsafe { on all }	

				}
				update_user_id {
					unsafe { on all }	

				}
				reading_time {
					unsafe { on all }	

				}
				public_at {
					validation {
						string {
							on all

						}

					}

				}
				tags {
					nosort { 0 }
					validation { 
						string { on { create update }  }
					}

				}
				status {
					validation {
						integer {
							on all

						}

					}

				}
				originaltranslation_id {
					validation {
						integer {
							on all

						}

					}

				}
				language {
					validation {
						string {
							on all

						}

					}

				}
				cms {
					validation {
						integer {
							on { create update }

						}

					}

				}



			}
			relations {
				author {column author_id fk_table users fk_column id fk_value username}
				update_user {column update_user_id fk_table users fk_column id fk_value username}
				tags {column id
		  			fk_table tags fk_column id  fk_value tag
		  			many_table blog_tags many_column post_id many_fk_column tag_id  }
				

			}

 }  
		set :alias { 
			id Id
			title Title
			slug Slug
			post Post
			creation_at {Creation at}
			author_id {Author id}
			update_at {Update at}
			update_user_id {Update user id}
			public_at {Public at}
			status Status
			originaltranslation_id "Original Translation"
			language "Language"
			tags Tags
			cms "CMS Type"

 }
		next 
	}

	:public method language {{lang ""}} {
		#Verify if the column is within language
	#	if { [my getScenario] ni [dict get $extra on] } { return 0 }
		set language [list "English" en "română" ro "Nederlands" nl "francais" fr Deutsch de  ]
		if {$lang != ""} {
			return [lindex $language [lsearch $language $lang]-1]
		}
		return $language
	}

	:public method status {{type ""}} {
		set status [list  [mc Draft] 0 [mc "Published Public"] 1 [mc "Published Authenticated"] 2 [mc Archived] 3  [mc "Published Authenticated, Public preview"] 4 [mc "Featured"] 5 ]
		if {$type != ""} {
			return [lindex $status [lsearch $status $type]-1]
		}
		return $status
	}

	:public method showTags {} {
	 	set tags [:relations tags ]
		set newtags ""
		foreach tag $tags {
			#append newtags $tag " "
			append newtags [${:bhtml} link -controller blog -htmlOptions [list class {label label-success}] $tag tag/[ns_urlencode $tag]] " " 
		#	append newtags [${:bhtml} link -controller blog -htmlOptions  [list class "label label-success"] $tag tag [list tag  $tag] ] " " 
		}
		return $newtags
	}
	:public method showHtml {data} {
		return [ns_unescapehtml $data]
	}
	:public method getLatestPosts {total} {
		#id title slug post creation_at author_id update_at update_user_id public_at status originaltranslation_id language
		set latestposts ""	
		set allowedStatus [list 1 3 4 5]
		if {[ns_session contains userid]} { lappend allowedStatus 2 }
		set criteria [SQLCriteria new -model [self]]
		$criteria add -fun in status $allowedStatus
		$criteria add -op <= public_at [getTimestamp] 
		$criteria add cms 0 
		set posts [my search -limit $total -orderType desc -order public_at -criteria $criteria "id title slug public_at"]	
	#	set bhtml [my bhtml]
		foreach [dict get $posts columns] [dict get $posts values] {
			set time [howlongago [scanTz $public_at]]
			set time $public_at
			append latestposts <p>[${:bhtml} tag small $time]<br>[${:bhtml} link -controller blog $title $slug]</p>
		}		
		return $latestposts
	}

	:public method getTagCloud {{-firstId 0} {-firstColumnName ""} -- {minShow 1}} {
		#-firstColumnName empty
		nx::next [list -interTbl blog_tags -interId post_id -firstTable blog_post -firstColumnName $firstColumnName $firstId $minShow]
	}

	:public method getTagTotals {{minShow 1} {grid 0} {begin_date ""} {end_date ""}} {
		 next  [list -interTbl blog_tags -interId post_id -firstTable blog_post  -dateColumn spent_at \
		  -valueColumn id -grid $grid 0 $minShow $begin_date $end_date]
	}

	:public method addTags {tags} {
		next [list -interTbl blog_tags -interId post_id $tags]
	}


	:public method getTags {} {
		next [list  -interTbl blog_tags -interId post_id ]
	}	
	:public method updateTags {oldTags newTags} {
		next [list  -interTbl blog_tags -interId post_id $oldTags $newTags]
	}
	:public method removeTags {oldTags newTags} {
		next [list  -interTbl blog_tags -interId post_id $oldTags $newTags]
	}

 
}

