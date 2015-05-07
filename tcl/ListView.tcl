##########################################
#  List View
# 	giving a "view" location and make a list from it:)
# 	or select a "view" from a detailview.. or something similair..
##########################################
nx::Class create ListView -superclass [list bhtml] {
	:property bhtml:object,type=bhtml
	:property {perpage 10}
	:property {page 1}
	:property {sort id}
	:property {sort_type asc}

	:property {extraUrlVars ""} 

	:property {relations 0}
	:property {toSelect *} 
	:property {class ""} 
	:property {showTopPagination 0}

	:property view:required
	:property model:required
	:property {searchOptions ""}





	:method init {} {
		set :table [${:model} getTable]
		set bhtml [self ]

		set :pr_stmt ""
		set :where_sql ""

		if {[ns_queryexists ${:table}_page]} { set :page [ns_queryget ${:table}_page 1] }
		if {[ns_queryexists ${:table}_perpage]} { set :perpage [ns_queryget ${:table}_perpage 10] }
		set ${:table}_sort ${:sort}

		:listViewGetFromDatabase

		:pageVerifications	

		:listViewSearch
		#-extraUrlVars $extraUrlVars
		set extraData ""

	}	

	:method pageVerifications {  } {

		if {![string is integer ${:perpage}]} { set :perpage 10 }
		if {![string is integer ${:page}]} { set :page 1 }
		if {${:perpage} < 1} { set :perpage 1 }
		if {${:perpage} > 100} { set :perpage 100 }
		set :lastpage [expr {int(ceil(double(${:size})/${:perpage}))}]
		#Verify if page isn't outside our borders
		if {${:page} < 1} { set :page 1 } elseif {${:page} > ${:lastpage} } { set :page ${:lastpage} }

	}

	:method listViewGetFromDatabase {args} {
		set where_loc [lsearch ${:searchOptions} -criteria]

		if {$where_loc != -1} {
			set criteria [lindex ${:searchOptions} $where_loc+1]
			append :where_sql "WHERE "  [$criteria getCriteriaSQL]
			set :pr_stmt [dict merge ${:pr_stmt} [$criteria getPreparedStatements ]]
		}

		dbi_1row  -db [${:model} db get ] -bind ${:pr_stmt} "SELECT count(*) as size FROM ${:table}  ${:where_sql};"
		if {$size == 0} { return [my htmltag div [msgcat::mc  "No data has been found, try adding something!" ]] }	
		set :size $size

	}
	:method listViewSearch {  } {
		lappend :searchOptions -offset [expr {${:perpage}*(${:page}-1)}] -limit ${:perpage} -order ${:sort} -orderType ${:sort_type} 

		set data [${:model} search {*}[concat ${:searchOptions}] ${:toSelect} ]

		if {$data == ""} { return [mc "No data has been found, try adding something!"]}

		set columns [dict get $data columns]
		foreach	$columns [dict get $data values]   {
			set method ""
			foreach v $columns {
				lappend method $v  $$v 
				#	${:model} set $v [subst $$v] 
			}
			${:model} set  {*}[subst $method]
			set bhtml ${:bhtml}
			set model ${:model}
			append :page_data  [ns_adp_parse   -file ${:view}.adp     {*}$method]
			#append :page_data  [ns_adp_parse   -file ${:view}.adp   bhtml $bhtml model ${:model}  {*}$method]
		}
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
		#method body
		return [:generateListViewWithPagination]
	}
	
}
