nx::Class create GridView -superclass [list bhtml] {

	:property bhtml:required,object,type=bhtml

	:property {url ""}   
	:property {urlClass ""}   
#TODO OPTIONS CAN BE GIVEN INTO A DICT?
#TODO very important: VERIFY DATA AND DON'T GIVE IT TO DB IF NOT CORRECT
#Give DICT with settings for each column..
#
#Be sure the ID/PK is the first selected, always
##WARNING makeAllLinks is incompatible with admin! (suite yourself!)
#When selecting always get the primary key..? but show it only if needed
#Set hideFirstColumn = 1 if you need to hide the primary key
	:property {toSelect *} 
	:property {class ""}   
	:property {perpage 10} 
	:property {maxPerPage 100}

	:property {page 1} 
	:property {sort id} 
	:property {defSort asc} 
	:property {admin 0} 
	#NOT IMPLEMENTED YET!
	:property {adminColumn ""} 
	:property {searchBar 0}

	#	-makeAllLinks makes links as default but it can also make the links as you want them..
	:property {makeAllLinks 0} 
	:property {hideFirstColumn 0} 

	# -specialFunctions column-name model-function-name
	#		for each value in this column it runs the data it has 
	#		with model-function-name and returns the value
	#		This is usefulll when you have a "raw" column
	#		and there exists no relation/foreign key to get its value
	#		so you make a function that converts it to the right value..
	#
	:property {specialFunctions ""} 
	:property {allowedSort ""} 
	:property {rowId 0}

	:property {cache 0} 
	:property {externalData 0} 
	:property {extraData ""} 
	:property {extraUrlVars ""} 
	:property model:Object,type=Model,required 
	:property {searchOptions ""} 

	:variable pr_stmt ""

	:method init {} {
		set :table [${:model} getTable]

		#Give this model a bhtml object reference..
		#so we don't generate 100 bhtml objects for grids where we need them
		${:model} bhtml ${:bhtml}
		set :originalSort ${:sort}
		
		:queryInfo
	}

	:method queryInfo {} {
	#Implement the pagination from within by getting the query 
	#Cleaner code and faster implementation
		if {[ns_queryexists ${:table}_page]} { set :page [ns_queryget ${:table}_page 1] }
		if {[ns_queryexists ${:table}_perpage]} { set :perpage [ns_queryget ${:table}_perpage 10] }
		if {[ns_queryexists ${:table}_sort]} { set :sort [ns_queryget ${:table}_sort ${:sort}] }
		#If somehow , sort manage to be something else than what exists as columns
		#OR it's not even originalSort specified.. resort to originalSort which is usually id
		#OR specified
		if {![${:model} exists ${:sort}]} { if {${:sort} ni ${:allowedSort}} { set :sort ${:originalSort} } }
		set :sort_type [ns_queryget sort ${:defSort}] 

	}

	#CACHING system implemented for your ease..
	#if no cache time.. expire NOW
	#key, time, value 
	#For caching we don't want to use ${:model} ..
	:public method getGridView {} {

		set forcache "${:toSelect} ${:perpage} ${:page} ${:sort} ${:sort_type} ${:admin} ${:makeAllLinks} ${:hideFirstColumn} ${:extraUrlVars} ${:specialFunctions} ${:searchOptions}"
		ns_parseargs {{-key ""} time}	${:cache}
		if {$key == ""} { 
			set key [ns_sha1  $forcache]
		}
		#	puts "Evaluating cache with key $key"
		# TODO cache based on website domain name>?
		# TODO Caching system saved in files,naviserver and redis
		set cache	[ns_cache_eval -timeout 5 -expires $time lostmvc GridView.$key  { 
			:gridView
		}]

		${:bhtml} setDataFromCache [dict get $cache bhtml]
		return [dict get $cache data]
	}

	:public method gridView {} {
		:processExternalData
		:pageCalculation
		:searchData

		:columnSubFunction
		:makeAllValuesLinks 

		:processColumns
		:gridSorting

		return [dict create data [:generateGridViewWithPagination] bhtml [${:bhtml} getCacheData]   ]
	}

	#External data means you use a dictionary or function like the following:
	#You need to provide the SQL , prepared statements and sql for the size select
	#	return [dict create sql_select  $sql_select pr_stmt $pr_stmt sql_size $sql_size]

	:method processExternalData {} {

		if {${:externalData} != 0} {
			foreach {k v} ${:externalData} { set :$k $v }
			dbi_1row  -db [${:model} db get ] -bind ${:pr_stmt} ${:sql_size}
			set :size $size
		}

		if {${:externalData} == 0} {

			set pr_stmt ""
			set where_sql ""
			set where_loc [lsearch ${:searchOptions} -criteria]
			set from  ${:table} 

			if {$where_loc != -1} {
				set criteria [lindex ${:searchOptions} $where_loc+1]
				set relations [SQLRelations new -model ${:model} -criteria $criteria  -statistics 1]
				$relations computeRelations * 
				append where_sql "WHERE "  [$criteria getCriteriaSQL]
				set pr_stmt [dict merge $pr_stmt [$criteria getPreparedStatements]]

				append from [$relations getFrom]
		}
			#SELECT count(*)
			#	FROM information_schema.columns
			#	WHERE table_name = '<table_name>'
	

			dbi_1row  -db [${:model} db get ] -bind $pr_stmt "SELECT count(*) as size FROM ${from}  $where_sql;"
			set :size $size
		}

		if {${:externalData} != 0} {
			lappend :searchOptions -selectSql [list ${:sql_select}  ${:pr_stmt}]
		}
	}

	:method pageCalculation {} {
		if {${:size} == 0} { 
			return -level 2	[dict create data [:alert -type info [msgcat::mc "There is no data available"]]  bhtml [${:bhtml} getCacheData]] 
		}

		#some verifications
		if {${:sort_type} != "asc" && ${:sort_type} != "desc"} {set :sort_type ${:defSort} }	

		if {![string is integer ${:perpage}]} { set :perpage 10 }
		if {![string is integer ${:page}]} { set :page 1 }
		if {${:perpage} < 5} { set :perpage 5 }
		if {${:perpage} > ${:maxPerPage}} { set :perpage ${:maxPerPage} }
		set :lastpage [expr {int(ceil(double(${:size})/${:perpage}))}]

		#Verify if page isn't outside our borders
		if {${:page} < 1} { set page 1 } elseif {${:page} > ${:lastpage} } { set page ${:lastpage} }
		lappend :searchOptions -offset [expr {${:perpage}*(${:page}-1)}] -limit ${:perpage} -order ${:sort} -orderType ${:sort_type} 
	} 

	:method searchData {} {

	#set other_get_opts "&{table}_sort=${:sort}&${:table}_page=$page&${:table}_perpage=$perpage&sort=${sort_type}"
		set :data [${:model} search {*}[concat ${:searchOptions}] ${:toSelect} ]
		#puts "GridView searchdata ${:data}"
		if {${:data} == ""} { 
			return -level 2 	[dict create data [:alert -type info [msgcat::mc "No data has been found, try adding something!"]]  bhtml [${:bhtml} getCacheData]] 
		}

		#Add an extra column to the data to editeverything..
		set :columnsize [llength [dict get ${:data} columns]]
		set :datasize [llength [dict get ${:data} values]]

		set :valuesdata [dict get ${:data} values]

	}

	:method columnSubFunction {} {
		set functions ""
		set newvaluesdata ""
		if {${:specialFunctions} != ""} {
			set count 0
			foreach col [dict get ${:data} columns] {
				if {$col in ${:specialFunctions}} {
					set fun [lindex ${:specialFunctions} [lsearch ${:specialFunctions} $col]+1]	
					lappend functions $count $fun
					dict set dictfunctions $count $fun
					#lappend locations  $count
					#lappend locations  [${:model} $fun [${:model} get $col]]
				} 
				incr count
			}
			set count 0
			#lsearch/lindex may be fast but wouldn't it be easier to just make
			#a dictionary and get it from there? DONE but commented
			foreach d ${:valuesdata} {
				if {[expr {$count%${:columnsize}}]==0} { 
				#Set the ID so we can use it later(if required..)
					#${:model} set id $d
					#Set rest of data so we can access it!
					set currentCount 0
					foreach col [dict get ${:data} columns] {
						${:model} set $col [lindex ${:valuesdata} $count+$currentCount ] 
						incr currentCount
					}
				}
				if {[set loc [expr {$count%${:columnsize}}]] in $functions } { 
					set fun [lindex $functions	[lsearch $functions $loc]+1]
					#	set fun [dict get $dictfunctions $loc]
					#	puts "Running function $fun for $d"

					set d [${:model} $fun $d]
				}
				lappend newvaluesdata $d
				incr count
			}
			set :valuesdata $newvaluesdata
			unset newvaluesdata  functions  ;#locations

		}
	}
	:method makeAllValuesLinks {} {

		if {${:makeAllLinks} != 0} {	
		#	ns_parseargs {{-type 0} -- link query} ${:makeAllLinks}

			set link "view" 
			set query id
			#Set to 1 if nothing else as difference
			if {${:makeAllLinks} != 1} {
				ns_parseargs {{-location 1} -- link {query id}} ${:makeAllLinks}
			} else {
				set location 1
			}
			#set location 1
			set count 1
			set vlength [llength ${:valuesdata}]
			foreach d ${:valuesdata} {
				set id [list [lindex ${:valuesdata} [expr {($count-1)/${:columnsize}*${:columnsize}+$location-1}] ]]
				lappend newvaluesdata [${:bhtml} link $d  $link "$query $id" ]
				#lappend newvaluesdata [${:bhtml} a $d  [ns_queryencode {*}$link $id] ]
				incr count
			}
			set :valuesdata $newvaluesdata
		}
	}

	:method searchBar {} {
	
		if {${:searchBar}} { 
		#Add extra row before data
			set bar ""	
			foreach col [dict get ${:data} columns] {
				set key [${:model} classKey $col]	
				lappend bar  [${:bhtml} input -id $key $key ]  
			}
			if {${:admin}} {
				;#THIS is for the extra edit/admin column:) 
				lappend bar   [${:bhtml}  input -type submit  -class "btn btn-primary" submit [mc "Search"]]  
			}
			if {${:rowId}} {
				lappend :mydata $bar
			} else { append :mydata " " $bar }
		}
	}

	:method hideFirstColumn {} {
			#This hides the first column usually the "id" column
		if {${:hideFirstColumn}} {
			set :varincr 1
			dict set :data columns  [lrange [dict get ${:data} columns] 1 end]
			#	incr columnsize -1
		} 

	}

	:method processColumns {} {
		set :varincr 0
		:hideFirstColumn
		:searchBar
		for {set var 0} {$var < ${:datasize} } {incr var ${:columnsize}} {
			set id [lindex ${:valuesdata} $var]

			if {${:admin}} {
				#TODO implement adminColumn # with templates
				set query ""
				if {${:adminColumn} == ""} {
					set view  [${:bhtml} link  "[${:bhtml} fa fa-eye] [mc View]" view [list id $id]]
					set delete  [${:bhtml} link -new 1   "[${:bhtml} fa fa-trash-o ] [mc Delete]" delete [list id $id]]
					set edit  [${:bhtml} link   "[${:bhtml} fa fa-pencil] [mc Update]" update [list id $id]]

					set adminoptions [concat $view $edit $delete]
				} else {
					#TODO NOT IMPLEMENTED YET!
					set adminoptions ""
			
				}

				#TODO add extra columns..
				if {${:rowId}} {
					lappend :mydata [format "%s %s {%s}" "-id $id"   [lrange ${:valuesdata} [expr $var+${:varincr}] [expr {$var+${:columnsize}-1}]] $adminoptions   ] 
				} else {
					append :mydata " " [format "%s {%s}"  [lrange ${:valuesdata} [expr $var+${:varincr}] [expr {$var+${:columnsize}-1}]] $adminoptions   ] 
				}
			} else {
				if {${:rowId}} {
					lappend :mydata [format "%s %s" "-id $id"  [lrange ${:valuesdata} [expr $var+${:varincr}] [expr {$var+${:columnsize}-1}]]]
				} else {
					append :mydata " " [lrange ${:valuesdata} [expr $var+${:varincr}] [expr {$var+${:columnsize}-1}]]
				}
			}
		}
	}

	:method gridSorting {  } {
		if {${:sort_type} == "asc"} { set newsort_type "desc" } else { set newsort_type "asc" }
		foreach th [dict get ${:data} columns] {
			lappend :tablehead [format {-url 1 -simple 1 -class  "%s"  "%s" "%s" } ${:urlClass} [${:model} getAlias $th] \
				${:url}[ns_queryencode ${:table}_sort $th	sort ${newsort_type}	${:table}_page ${:page}		${:table}_perpage ${:perpage}	{*}${:extraUrlVars}]]
		}
	}
	
	:method generateGridViewWithPagination {  } {
		if {${:admin}} {	 lappend :tablehead [mc "Edit"] }
		if {${:rowId}} {
		#	set :mydata  ${:mydata}  ]
		}
		if {![info exists :mydata]} { return [:alert -type info [msgcat::mc "There is no data available"]] }
		set :tablehtml [${:bhtml} table -class "" -bordered 1 -striped 1 -hover 1  -rpr ${:rowId}   ${:tablehead}   ${:mydata} ]
		
		set pagination [Pagination new -size ${:size} -extraUrlVars ${:extraUrlVars} -page ${:page} \
			-table ${:table} -lastpage ${:lastpage} -perpage ${:perpage} -sort ${:sort} -sort_type ${:sort_type} -url ${:url} -urlClass ${:urlClass}]	
	
		set divPagination [$pagination divPagination get]
		set pageInfo [$pagination pageInfo get]
		set perPageDiv  [$pagination perPageDiv get]

		set clearfix [${:bhtml} htmltag -htmlOptions [list class clearfix] div]
		set return [${:bhtml} htmltag -htmlOptions [list class ${:class}] div "$divPagination  $pageInfo \n $clearfix  \n 
			${:extraData} \n\n  ${:tablehtml}  \n\n $divPagination $perPageDiv  $clearfix"]
		return  $return

	}


}
