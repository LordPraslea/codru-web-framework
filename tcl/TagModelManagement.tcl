#################################	
# Tags Model management, can be used everywhere!
#################################	
nx::Class create TagModelManagement {

	#Adds tags to the specified table
	:public method addTags {{-interTbl } {-tagsTbl tags} {-interId  } --  tags} {
		set this_id [:get id]
		set db [:db get]
		set whereCriteria [SQLCriteria new -table $tagsTbl]
		set :tagsList [split $tags ","]
	

		#Find if tags exist in tags column
		foreach {tag} ${:tagsList} {
			$whereCriteria add -cond OR tag $tag 
		}

		set data [:search -table $tagsTbl -criteria $whereCriteria [list tag id]]
		set values [dict get $data values]

		:addTagsList 
		:addInterTableTags 

		return true
	}

	#TODO REWRITE TO USE INSERT FUNCTION! 
	:method addTagsList {} {
		foreach refVar {values tagsTbl interId interTbl this_id} { :upvar $refVar $refVar }
		set :addedTagList ""
		set :existingids ""
		set :existingtags ""
		set pr_stmt ""
		
		set whereCriteria [SQLCriteria new -table $tagsTbl]
		
		foreach tag ${:tagsList} {
			#if tag is not in values.. then it means it's a fresh tag for our tags list #we ADD it!
			if {[lsearch -nocase  $values $tag] == -1} {
				unset pr_stmt
				dict set pr_stmt tag $tag
				set sql "INSERT INTO $tagsTbl (tag) VALUES (:tag) RETURNING id"
				set id  [dbi_0or1row -db ${:db} -array mytag -bind $pr_stmt $sql] 
				lappend :addedTagList $mytag(id)
			} else {
				#This tag exists in values, verifying if it's linked..
				##Get the right position
				set id [lindex $values [lsearch -nocase $values $tag]+1]
				dict set pr_stmt tag_id  $id		
				dict set pr_stmt $interId $this_id

				set sql_select "SELECT * FROM $interTbl WHERE tag_id = :tag_id AND $interId = :$interId "
				set linkedid  [dbi_0or1row -db ${:db}  -bind $pr_stmt $sql_select ]
				
				if {$linkedid} {			
					lappend :existingids $id
					lappend :existingtags $tag $id
				}
				lappend :addedTagList $id

			}

		}
	}

	:method addInterTableTags {} {

		foreach refVar {values tagsTbl interId interTbl this_id} { :upvar $refVar $refVar }
		#TODO 1 big insert..
		foreach id ${:addedTagList} {
			#verify if this id isn't in existingids, if it isn't add it..
			if {$id ni ${:existingtags}} {
				set pr_stmt ""
				dict set pr_stmt $interId $this_id
				dict set pr_stmt tag_id $id

			#	puts "Combining (esm_id,tag_id) ($esm_id,$id)"
				set sql "INSERT INTO $interTbl ($interId,tag_id) VALUES (:$interId,:tag_id)"
				set id  [dbi_dml -db ${:db} -bind $pr_stmt $sql] 
			}
		}
	}

	#TODO this will need to be rewritten to fit relations with model
	:public method getTags {{-interTbl } {-tagsTbl tags} {-interId  } } {
		#set sql_select "SELECT tag FROM tags t, esm_tags et WHERE "
		dict set pr_stmt $interId [my get id]
		set sql_select "SELECT tag FROM $tagsTbl t JOIN $interTbl et  ON t.id=et.tag_id WHERE et.$interId=:$interId "
		set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt $sql_select ]
		#set tags? or just return them..?
	#	puts "$values and [split $values ,] and [join $values ,]"
		set values [join $values ","]
		my set tags  $values 
		return $values
	}

	:public method removeTags {{-interTbl } {-tagsTbl tags} {-interId  } -- oldTags newTags } {
		#compare oldTags to newTags (find the unique)
		#remove those that are not in that list
		set first 0
		set oldTags [split $oldTags ,]
		set newTags [split $newTags ,]
	#	puts "OldTags $oldTags and newtags $newTags"
		set deleteTags ""
		foreach tag $oldTags {
			#Fixed ni (not in list) case sensitive  
			#if {$tag ni $newTags}   
			if {[lsearch -nocase  $newTags $tag] == -1} {
				lappend deleteTags $tag
			}	
		}	
		#Only delete if there are tags removed..
		if {$deleteTags != ""} {
			set criteria [SQLCriteria new -table $tagsTbl]
			$criteria add -fun in tag  $deleteTags
			set idTags [my search -table $tagsTbl  -criteria $criteria  id]
			if {$idTags ==""} { return "Empty" }
			# puts "Nothing to delete.. because deleteTags $deleteTags couldn't find anything"; 
		#	puts "Found and will delete idTags [dict get $idTags values]"
			set deleteCriteria [SQLCriteria new -table $interTbl]
			$deleteCriteria add -fun  IN tag_id [dict get $idTags values]
			$deleteCriteria add $interId [:get id]
			my deleteOther -table $interTbl -deleteCriteria  $deleteCriteria
		} 
	}

	:public method updateTags {{-interTbl } {-tagsTbl tags} {-interId  } -- oldTags newTags } {
		#Update Tags (either by adding new ones or removing)
		#IF you've overwritten addTags and removeTags.. then these can be simple ones
	#	my addTags  -interTbl $interTbl -tagsTbl $tagsTbl -interId $interId $newTags
	#	my removeTags -interTbl $interTbl -tagsTbl $tagsTbl -interId $interId  $oldTags $newTags
		my addTags $newTags
		my removeTags $oldTags $newTags
	}

	#Selecting the TAG data from the database
	# firstTable is the original table for which we have firstTable_tags linkage with tags
	:public method getTagCloud {{-interTbl } {-tagsTbl tags}  {-interId  } {-firstTable }
							 {-firstColumnName ""} {-extraOptions ""} --  {firstId 0 } {minShow 1} } {
		set sql_select "SELECT $tagsTbl.id,$tagsTbl.tag, count($tagsTbl.id) as Count
		FROM $firstTable,$tagsTbl,$interTbl
		WHERE $firstTable.id   =  $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id
		"
		if {$firstColumnName != ""} {
			append sql_select "	AND $firstTable.$firstColumnName=:firstid"

			dict set pr_stmt firstid $firstId
		}
		append sql_select " GROUP BY $tagsTbl.tag,$tagsTbl.id
		HAVING count($tagsTbl.id)>=:minshow
		ORDER BY $tagsTbl.tag ASC"

		dict set pr_stmt minshow $minShow
			set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt {*}$extraOptions $sql_select ]
			return [dict create columns $columns values $values ]
		
	}

	#	gets the tag totals for a specific userid 
	#	and a count value for some kind of sum..
	:public method getTagTotals {{-interTbl } {-tagsTbl tags}  {-interId  } {-firstTable } {-firstColumnName ""} {-dateColumn }
							  {-valueColumn} {-grid 0}  {-extraOptions ""}	--  {firstId} {minShow 1} {begin_date ""} {end_date ""} } { 

		#This selects distinct values!
		set sql_size "
		SELECT  count(DISTINCT $tagsTbl.id) as size
		FROM $firstTable,$interTbl,$tagsTbl
		WHERE $firstTable.id   = $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id "

	set sql_select	"SELECT $tagsTbl.id,$tagsTbl.tag,count($tagsTbl.id) as Count,sum($firstTable.$valueColumn) as Total
		FROM $firstTable,$tagsTbl,$interTbl
		WHERE $firstTable.id   = $interTbl.$interId 
		AND $interTbl.tag_id = $tagsTbl.id 	"
		if {$firstColumnName != ""} {
			append sql_select "	AND $firstTable.$firstColumnName=:firstid "
			append sql_size "	AND $firstTable.$firstColumnName=:firstid "

			dict set pr_stmt firstid $firstId
		}

		if {$begin_date != "" && $end_date != "" } {
			append sql_size " AND $firstTable.$dateColumn BETWEEN :begin_date AND :end_date "
			append sql_select " AND $firstTable.$dateColumn BETWEEN :begin_date AND :end_date "

			dict set pr_stmt begin_date $begin_date
			dict set pr_stmt end_date $end_date
		}
		append sql_select "	GROUP BY $tagsTbl.tag,$tagsTbl.id
		HAVING sum($firstTable.$valueColumn)>= :minshow"
		dict set pr_stmt minshow $minShow

		if {!$grid} {
			set values  [dbi_rows -db [my db get] -columns columns -bind $pr_stmt {*}$extraOptions $sql_select ]
			return [dict create columns $columns values $values ]
		} else {
			return [dict create sql_select  $sql_select pr_stmt $pr_stmt sql_size $sql_size]
		}

	}
}
