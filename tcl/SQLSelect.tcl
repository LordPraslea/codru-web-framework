#################################	
# SQL Select (Search) 
#################################	

nx::Class create SQLSelect   {
	
	:property sql_select

	:method findByCriteria {{-relations 0} {-save 1} {-type pk} -- value } {
		set table [dict get ${:attributes} table]
		set from $table
		set toSelect *
		
		if {$type == "pk"} {
			set idValueList $value
			set criteria [SQLCriteria new -table $table ]
			:addPrimaryKeyCriteria
		} else {
			set criteria $value
		}

		:generateRelationData

		set where_sql [$criteria  getCriteriaSQL]
		set pr_stmt  [$criteria getPreparedStatements]

		
		set sql_select "SELECT $toSelect FROM $from WHERE $where_sql"
		set result [dbi_0or1row -db ${:db} -array data -bind $pr_stmt $sql_select ]
		
		if {$save} {
			:set {*}[array get data]
			set :newRecord 0
			set :scenario update
		}
		return $result
	}

	#  Search one row by any conditions .
	:public method findByCondition {{-relations 0} {-save 1} criteria:object,type=SQLCriteria } {
			return [:findByCriteria -relations $relations -save $save -type condition $criteria]
	}

	:public method findByCond {{-relations 0} {-save 1} criteria:object,type=SQLCriteria } {
			return [:findByCriteria -relations $relations -save $save -type condition $criteria]
	}


	#	:public alias findByCond [:info method handle findByCondition ]
	#Find row by primary keys
	:public method findByPrimaryKey {{-relations 0} {-save 1} -- idValueList } {
		return [:findByCriteria -relations $relations -save $save -type pk $idValueList]
	}	
	
	:public method findByPk {{-relations 0} {-save 1} -- idValueList } {
		return [:findByCriteria -relations $relations -save $save -type pk $idValueList]
	}

#	:public alias findByPk [:info method handle findByPrimaryKey]

	:method genSelectConditions {selectList} {
		set toSelect ""
		set first 0

		foreach currentSelect $selectList {
			set separator [expr {$first==0? "" : ", "}]
			append toSelect $separator $currentSelect 
			incr first
		}
		return $toSelect
	}

	:method generateRelationData {} {
		foreach refVar {relations table criteria from toSelect } { :upvar $refVar $refVar }
		if {$relations} {	
			set sqlrelations [SQLRelations new -table $table -model [self] -criteria $criteria -select $toSelect  ]
			append from [$sqlrelations getFrom]
			
			set toSelect [$sqlrelations getToSelect]
		}
		if {$toSelect != "*"} {
			set toSelect [:genSelectConditions $toSelect]
		}
	}

	:method addPrimaryKeyCriteria {} {
		foreach refVar {criteria  idValueList} { :upvar $refVar $refVar }
		set primarykeys [dict get ${:attributes} primarykey] 

		foreach id $primarykeys idValue $idValueList	 {
			$criteria add $id $idValue
		}
	}

	# Function that searches for multiple data in the database..
	#TODO differentiate between 1 row (set object) and many (return values)
	#TODO prstmt not used yet.. could be used with selectSql
	#TODO view if limit empty and if only a number, view if offset is a number..
	#	TODO 	{-orderType:choice,arg=asc|desc asc}  
	:public method search {{-relations 0} 
						{-table ""} 
						{-limit:integer -1} 
						{-offset:integer -1}
						{-criteria:object,type=SQLCriteria }
						{-where ""}
						{-order ""}
						{-orderType asc} 
						{-selectSql ""}
						{-pr_stmt ""} -- {toSelect *}
	} {
		set :sql_select ""
		set :pr_stmt $pr_stmt
		set where_sql ""
		set from ""
		if {![info exists criteria]} {
			set criteria [SQLCriteria new -model [self]]
		}
		
		#DEBUG purposes, to be removed when things have been rewritten..
		if {$where !=""} {  error "Model / SQLSelect / Search: -where option has been replaced by -criteria (SQLCriteria object)" }
		
		if {$table == ""} {
			set table [dict get ${:attributes} table]
		}

		if {$selectSql == ""} {
			:computeSearchSQL
		} else { 
			set :sql_select [lindex  $selectSql 0] ; set :pr_stmt [lindex $selectSql 1]
		}

		if {$order != ""} {
			:computeSearchOrder
		}
		:selectProcessLimit 

		:selectProcessOffset 
	
		my sqlstats ${:sql_select}
		#puts "SEARCH PRSTMT   ${:pr_stmt} \n SQL ${:sql_select}\n"
		set values  [dbi_rows -db ${:db} -columns columns -bind ${:pr_stmt} ${:sql_select} ]
		return [dict create columns $columns values $values ]
	}

	:method selectProcessLimit {} {
		upvar limit limit
		if {$limit != -1} {
			dict set :pr_stmt limit $limit 
			append :sql_select " LIMIT :limit "
		}
	}

	:method selectProcessOffset {} {
		upvar offset offset
		if {$offset != -1} {
			dict set :pr_stmt offset $offset 
			append :sql_select " OFFSET :offset "
		}
	}

	:method computeSearchSQL {} {
		foreach refVar {table toSelect criteria relations } { :upvar $refVar $refVar }

		set from $table

		if {$toSelect == "*"} {
			set toSelect "${table}.*" 
		}
		:generateRelationData 

		set where_sql [$criteria  getCriteriaSQL]
		set :pr_stmt  [dict merge ${:pr_stmt} [$criteria getPreparedStatements]]

		append :sql_select "SELECT $toSelect "
		append :sql_select "FROM $from "
		
		if {$where_sql != ""} {
			append :sql_select "WHERE $where_sql "
		}
	}

	#Sorting normal sqlcolumns and by relations.

	#We only need the real columns, since we define a name for the relations
	#and the relations don't need table.column since they're defined in "as"
	
	:method computeSearchOrder {} {
		foreach refVar {order orderType table from } { :upvar $refVar $refVar }

		set orderColumn  ""
		if {[dict exists ${:attributes} sqlcolumns $order] } {
			if {![dict exists ${:attributes} sqlcolumns $order nosort]} {
				set orderColumn $table.$order 
			}
		} elseif {[dict exists ${:attributes} relations $order] } {
			if {[dict exists ${:attributes} relations $order fk_table]} {
				foreach {k v} [dict get ${:attributes} relations $order] { set $k $v }

				set orderColumn $fk_table.$fk_value
				if {[lsearch -nocase $from $fk_table] ==-1} { 
					set orderColumn "$column"
				}
			} else { set order id }
		}	
		if {$orderColumn != ""} {
			append :sql_select " ORDER BY $orderColumn $orderType " ;
		} else { append :sql_select " ORDER BY $order $orderType "  }
	}

}
