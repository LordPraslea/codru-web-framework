##########################################
#  List View
# 	giving a "view" location and make a list from it:)
# 	or select a "view" from a detailview.. or something similair..
##########################################
##TODO CACHE!
nx::Class create ListView -superclass [list bhtml] {
	:property bhtml:object,type=bhtml
	:property {perpage 10}
	:property {maxPerPage 50}
	:property {page 1}
	:property {sort id}
	:property {sort_type asc}

	#Options that work: 1 2 3 4  
	#work only if you have big screens and/or have enough space 6 12
	:property {perRow 1}

	:property {extraUrlVars ""} 
	#TODO NOT IMPLEMENTED YET, make it easier so you don't need to do -searchOptions [list -relations 1]
	

	:property {relations 0}
	:property {toSelect *} 
	:property {class ""} 
	:property {showTopPagination 0}

	:property view:required
	:property model:required
	:property {searchOptions ""}

	:property {externalData 0} 

	:property {cache 0}

	:method init {} {
		set :table [${:model} getTable]

		:listViewInitVariables

		
		if {[ns_queryexists ${:table}_page]} { set :page [ns_queryget ${:table}_page 1] }
		if {[ns_queryexists ${:table}_perpage]} { set :perpage [ns_queryget ${:table}_perpage 10] }

		if {[ns_queryexists ${:table}_sort]} { set :sort [ns_queryget ${:table}_sort ${:sort}] }
		if {![${:model} exists ${:sort}]}  {
			set :sort ${:originalSort}	
		}

		set :sort_type [ns_queryget sort ${:sort_type}] 
		if {${:sort_type} != "asc" && ${:sort_type} != "desc"} {set :sort_type ${:originalSortType} }	

		if {${:perRow} ni "1 2 3 4 6 12"} { 
			append :page_data [${:bhtml} alert -type warning "WARNING ListView Option -perRow must be only one of the following \"1 2 3 4 6 12\"  "] 	
		}
	}	


	:method listViewInitVariables {  } {
		set :pr_stmt ""
		set :where_sql ""

		set extraData ""

		set :currentColumn 1
		set :row_data ""
		set :page_data ""

		set :originalSort ${:sort}
		set :originalSortType  ${:sort_type}

	}

	:method processExternalData {} {

		if {${:externalData} != 0} {
			foreach {k v} ${:externalData} { set :$k $v }
			dbi_1row  -db [${:model} db get ] -bind ${:pr_stmt} ${:sql_size}
			set :size $size
			if {$size == 0} { return -level 2 [:alert -type info [msgcat::mc  "No data has been found, try adding something!" ]] }	

			lappend :searchOptions -selectSql [list ${:sql_select}  ${:pr_stmt}]
		}
	}

	:method pageVerifications {  } {

		if {![string is integer ${:perpage}]} { set :perpage 10 }
		if {![string is integer ${:page}]} { set :page 1 }
		if {${:perpage} < 1} { set :perpage 1 }
		if {${:perpage} > ${:maxPerPage}} { set :perpage ${:maxPerPage} }
		set :lastpage [expr {int(ceil(double(${:size})/${:perpage}))}]
		#Verify if page isn't outside our borders
		if {${:page} < 1} { set :page 1 } elseif {${:page} > ${:lastpage} } { set :page ${:lastpage} }

	}

	:method listViewGetFromDatabase {args} {

		if {${:externalData} == 0} {
			set where_loc [lsearch ${:searchOptions} -criteria]

			if {$where_loc != -1} {
				set criteria [lindex ${:searchOptions} $where_loc+1]
				append :where_sql "WHERE "  [$criteria getCriteriaSQL]
				set :pr_stmt [dict merge ${:pr_stmt} [$criteria getPreparedStatements ]]
			}
			dbi_1row  -db [${:model} db get ] -bind ${:pr_stmt} "SELECT count(*) as size FROM ${:table}  ${:where_sql};"
			if {$size == 0} {
				return -level 2 	[dict create data [:alert -type info [msgcat::mc "No data has been found, try adding something!"]]  bhtml [${:bhtml} getCacheData]] 
			}	
			set :size $size
		}
	}

	:method listViewSearch {  } {
		set col [expr {12/${:perRow}}]

		lappend :searchOptions -offset [expr {${:perpage}*(${:page}-1)}] -limit ${:perpage} -order ${:sort} -orderType ${:sort_type} 

		set data [${:model} search {*}[concat ${:searchOptions}] ${:toSelect} ]

		if {$data == ""} {
			return -level 2 	[dict create data [:tag div [msgcat::mc "No data has been found, try adding something!"]]  bhtml [${:bhtml} getCacheData]] 
		}

		set columns [dict get $data columns]
		foreach	$columns [dict get $data values]   {
			set method ""
			foreach v $columns {
				lappend method $v  $$v 
			}
			${:model} set  {*}[subst $method]
			set bhtml ${:bhtml}
			set model ${:model}
			
			#Per Row Separation
			append :row_data  [ns_adp_parse   -file ${:view}.adp     {*}$method]
			if {[expr {${:currentColumn} % ${:perRow}}] == 0} {
				append :page_data [${:bhtml} tag -htmlOptions [list class row] div ${:row_data}] 
				set :row_data ""
			}

			incr :currentColumn
		}

		#Row_data may still contain data at the end of processing, put it in a div with a row class
		if {${:row_data} != ""} {
			append :page_data [${:bhtml} tag -htmlOptions [list class row] div ${:row_data}] 
		}
	}


	:method listViewPerRow {} {
		:upvar method method


	
	}

	:method generateListViewWithPagination {  } {

		set pagination [Pagination new -size ${:size} -extraUrlVars ${:extraUrlVars} -page ${:page} \
			-table ${:table} -lastpage ${:lastpage} -perpage ${:perpage} -sort ${:sort} -sort_type ${:sort_type}]	

		set divPagination [$pagination divPagination get]
		set pageInfo [$pagination pageInfo get]
		set perPageDiv  [$pagination perPageDiv get]


		set clearfix [my htmltag -htmlOptions [list class clearfix] div]
		#don't show to select how many to see per page..
		set perPageDiv ""
		if {${:showTopPagination} == 1} {
			set showpagination "$divPagination  $pageInfo \n $clearfix  \n $extraData \n\n"
		} else  {
			set showpagination ""
		}
		return [my htmltag -htmlOptions [list class ${:class}] div "$showpagination  ${:page_data}  \n\n $divPagination $perPageDiv  $clearfix"]

	}

	:public method getListView {args} {
		set forcache "${:toSelect} ${:view} ${:perpage} ${:page} ${:sort} ${:sort_type} " 

		append forcache "${:perRow} ${:extraUrlVars} ${:externalData} ${:showTopPagination} "
		
		set where_loc [lsearch ${:searchOptions} -criteria]
		if {$where_loc != -1} {
			set criteria [lindex ${:searchOptions} $where_loc+1]
			set cache_where  [$criteria getCriteriaSQL]
			set cache_pr_stmt [$criteria getPreparedStatements ]
			append forcache " [$criteria getCriteriaSQL] [$criteria getPreparedStatements ] "
		}
		
		puts "Forcache is $forcache"
		ns_parseargs {{-key ""} time}	${:cache}
		if {$key == ""} { 
			set key [ns_sha1  $forcache]
		}
		#	puts "Evaluating cache with key $key"
		#	#TODO key based on website domain?
		# TODO Caching system saved in files,naviserver and redis
		set cache [ns_cache_eval -timeout 5 -expires $time lostmvc ListView.$key  { 
			:processExternalData

			:listViewGetFromDatabase

			:pageVerifications	

			:listViewSearch
			return [dict create data [:generateListViewWithPagination] bhtml [${:bhtml} getCacheData]   ]
		}]
		
		${:bhtml} setDataFromCache [dict get $cache bhtml]
		return [dict get $cache data]

	}
	
}
