nx::Class create Pagination -superclass [list bhtml] {

	:property {url ""}
	:property {urlClass ""}

	:property {extraUrlVars "" } 
	:property {size 0} 
	:property page:required 
	:property table:required 
	:property lastpage:required 
	:property perpage:required  
	:property sort:required
	:property sort_type:required

	:variable -accessor public perPageDiv
	:variable -accessor public pageInfo
	:variable -accessor public divPagination


	:method paginationPreInit {} {
		set :forFirstPage 1
		set :forLastPage ${:lastpage}
		if {${:lastpage} > 10} {
			set :forFirstPage [expr {${:page}-5}] 
			set :forLastPage [expr {${:page}+5}]
			if {${:forFirstPage} < 1} { set :forFirstPage 1}
			if {${:forLastPage} > ${:lastpage}} { set :forLastPage ${:lastpage} }
		}
	}

	:method createPagination {} {
		for {set var ${:forFirstPage}} {$var <= ${:forLastPage} } {incr var} {
			if {$var != ${:page}} {
				set pageName "Page $var"
				lappend pagination "-url 1 -title [list $pageName] -class	[list ${:urlClass}]  $var	
				${:url}[ns_queryencode ${:table}_page $var 	${:table}_sort ${:sort} 	${:table}_perpage ${:perpage} 	sort ${:sort_type} 	{*}${:extraUrlVars}]"
			} else { lappend pagination "-active 1 -url 1  -class ${:urlClass}  # $var" }
		}

		set first [format {-url 1 -title "%s"  -class "%s" "&laquo;" "%s" } [mc "First page"] \
			${:urlClass}	${:url}[ns_queryencode ${:table}_page 1		${:table}_sort ${:sort}		${:table}_perpage ${:perpage}	sort ${:sort_type}	{*}${:extraUrlVars}]]
		set last [format {-url 1 -title "%s" -class "%s" "&raquo;" "%s" } [mc "Last page"] \
			${:urlClass} ${:url}[ns_queryencode ${:table}_page ${:lastpage}		${:table}_sort ${:sort}		${:table}_perpage ${:perpage} 	sort ${:sort_type}	{*}${:extraUrlVars}]]  

		set :htmlpagination [:pagination  -first $first -last $last   $pagination] 
	}

	#TODO per page.. show it on/off.. +/- set the value incoming from the settings..
	#	set perpage [bhtml htmltag -htmlOptions [list class "pull-right col-md-4"] p "Per page"]
	#	set perpagediv [my label -class "col-md-3 control-label"  [mc "Per page"]]
	:method generatePaginationForm {} {
		set perpagediv ""

		set selectdiv [my select -class "col-sm-4" -selected ${:perpage} {5  5 10 10 25 25 50 50 100 100} ${:table}_perpage]
		foreach {k v} ${:extraUrlVars} {
			append selectdiv [my input -type hidden $k $v]
		}
		set gosubmit [my input  -type submit submit [mc "Per page"]]
		set perpageform [my form -action ${:url}[ns_queryencode ${:table}_page ${:page}	${:table}_sort ${:sort}	 \
			{*}${:extraUrlVars}] "$selectdiv <br> $gosubmit"] 	
		append perpagediv " "  [my htmltag  -htmlOptions [list class [list col-sm-4 pull-right] style "max-width:110px;"] div  $perpageform ] ;#$selectdiv

		set :perPageDiv [my htmltag  div $perpagediv]
		set :pageInfo <p>[mc "Per page %d, total %d.<br> Page %d from %d. "  ${:perpage} ${:size} ${:page} ${:lastpage}]</p>
		set :divPagination [my htmltag -htmlOptions [list  "class" "text-left col-md-8"] div  ${:htmlpagination}   ]
	}

	:method init {} {
		:paginationPreInit
		:createPagination
		:generatePaginationForm 
	}
}
