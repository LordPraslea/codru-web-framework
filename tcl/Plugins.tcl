##########################################
# Bootstrap and jQuery plugin's
##########################################
#	 LostMVC -	 http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014 United Brain Power <info@unitedbrainpower.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#TODO view/edit data via json if javascript is on, simple if not..
#TODO  bulk aactions.. 
#
#TODO OPTIONS CAN BE GIVEN INTO A DICT?
#TODO very important: VERIFY DATA AND DON'T GIVE IT TO DB IF NOT CORRECT
#Give DICT with settings for each column..
#
#Be sure the ID/PK is the first selected, always
##WARNING makeAllLinks is incompatible with admin! (suite yourself!)
#When selecting always get the primary key..? but show it only if needed
#Set hideFirstColumn = 1 if you need to hide the primary key
::bhtml   public method gridView {{-toSelect *} {-class ""}   {-perpage 10} {-page 1} {-sort id} {-defSort asc} {-admin 0} {-search 0}
			   {-makeAllLinks 0} {-hideFirstColumn 0} {-specialFunctions ""} {-allowedSort ""} {-rowId 0}
								  {-cache 0} {-externalData 0} {-extraData ""} {-extraUrlVars ""} -- model {others ""}} {


								  # -specialFunctions column-name model-function-name
								  #		for each value in this column it runs the data it has 
								  #		with model-function-name and returns the value
								  #		This is usefulll when you have a "raw" column
								  #		and there exists no relation/foreign key to get its value
								  #		so you make a function that converts it to the right value..
								  #	-makeAllLinks makes links as default but it can also make the links as you want them..
#	ns_parseargs {{-type 0} -- link query} $makeAllLinks
	set table [$model getTable]
	#Give this model a bhtml object reference..
	#so we don't generate 100 bhtml objects for grids where we need them
	$model bhtml [self ]
	#puts "bhtml is [$model bhtml]"

	set originalSort $sort
	set pr_stmt ""
	#puts "Gridview model is $model and table is $table"
	#
	#Implement the pagination from within by getting the query 
	#Cleaner code and faster implementation
	if {[ns_queryexists ${table}_page]} { set page [ns_queryget ${table}_page 1] }
	if {[ns_queryexists ${table}_perpage]} { set perpage [ns_queryget ${table}_perpage 10] }
	if {[ns_queryexists ${table}_sort]} { set sort [ns_queryget ${table}_sort $sort] }
	#If somehow , sort manage to be something else than what exists as columns
	#OR it's not even originalSort specified.. resort to originalSort which is usually id
	#OR specified
	if {![$model exists $sort]} { if {$sort ni $allowedSort} { set sort $originalSort } }
	set sort_type [ns_queryget sort $defSort] 

	#CACHING system implemented for your ease..
	#if no cache time.. expire NOW
	#key, time, value 
	#For caching we don't want to use $model ..
	set forcache "$toSelect $perpage $page $sort $sort_type $admin $makeAllLinks $hideFirstColumn $extraUrlVars $specialFunctions $others"
	ns_parseargs {{-key ""} time}	$cache
	if {$key == ""} { 
		set key [::sha2::sha256 -hex $forcache]
	}
	#	puts "Evaluating cache with key $key"
	return	[ns_cache_eval -timeout 5 -expires $time lostmvc $key  { 
	#\}

	#External data means you use a dictionary or function like the following:
	#You need to provide the SQL , prepared statements and sql for the size select
	#	return [dict create sql_select  $sql_select pr_stmt $pr_stmt sql_size $sql_size]

		if {$externalData != 0} {
			foreach {k v} $externalData { set $k $v }
			dbi_1row  -db [$model db get ] -bind $pr_stmt $sql_size
		}
		#TODO if where exists, extract it.. and put it into the size.. so we know the exact size for specific selects!
		##TODO very important, make a unique "where" selection function!!!
		#TODO so we don't have 3-5 snippets of code everywhere
		#
		if {$externalData == 0} {
		#set where_loc -1
			set where_loc [lsearch $others -where]
			set pr_stmt ""

			set where_sql ""
			#puts "Whereloc $where_loc"
			if {$where_loc != -1} {

			#	set where [lindex $others $where_loc+1]
			set first 0
			set where [lindex $others $where_loc+1]

			set computewhere [$model computeWhere $where $first 1] 
			append where_sql "WHERE "  [dict get $computewhere where_sql]
			set pr_stmt [dict merge $pr_stmt [dict get $computewhere pr_stmt]]

		}
		#puts  "$pr_stmt \"SELECT count(*) as size FROM $table  $where_sql;"


		dbi_1row  -db [$model db get ] -bind $pr_stmt "SELECT count(*) as size FROM $table  $where_sql;"
	}
	#	puts "Ok nigga hit'em $args $where_sql and count $size"
	if {$size == 0} { return [my htmltag div [msgcat::mc "There is no data available"]] }	
	#SELECT count(*)
	#	FROM information_schema.columns
	#	WHERE table_name = '<table_name>'

	#some verifications
	if {$sort_type != "asc" && $sort_type != "desc"} {set sort_type $defSort }	


	if {![string is integer $perpage]} { set perpage 10 }
	if {![string is integer $page]} { set page 1 }
	if {$perpage < 5} { set perpage 5 }
	if {$perpage > 100} { set perpage 100 }
	set lastpage [expr {int(ceil(double($size)/$perpage))}]

	#Verify if page isn't outside our borders
	if {$page < 1} { set page 1 } elseif {$page > $lastpage } { set page $lastpage }
	lappend others -offset [expr {$perpage*($page-1)}] -limit $perpage -order $sort -orderType $sort_type 

	#set other_get_opts "&{table}_sort=$sort&${table}_page=$page&${table}_perpage=$perpage&sort=${sort_type}"
	#puts "For data $others and $toSelect"
	if {$externalData != 0} {
		lappend others -selectSql [list $sql_select  $pr_stmt]
	}
	#	puts "$model search {*}[concat $others] $toSelect  "	
	set data [$model search {*}[concat $others] $toSelect ]
	if {$data == ""} { return [mc "No data has been found, try adding something!"]}
	#If no data,return empty (means something went wrong?

	#Add an extra column to the data to editeverything..
	set columnsize [llength [dict get $data columns]]
	set datasize [llength [dict get $data values]]

	set valuesdata [dict get $data values]


	if {$specialFunctions != ""} {
		set count 0
		foreach col [dict get $data columns] {
			if {$col in $specialFunctions} {
				set fun [lindex $specialFunctions [lsearch $specialFunctions $col]+1]	
				lappend functions $count $fun
				dict set dictfunctions $count $fun
				#lappend locations  $count
				#lappend locations  [$model $fun [$model get $col]]
			} 
			incr count
		}
		set count 0
		#lsearch/lindex may be fast but wouldn't it be easier to just make
		#a dictionary and get it from there? DONE but commented
		foreach d $valuesdata {
			if {[expr {$count%$columnsize}]==0} { 
			#Set the ID so we can use it later(if required..)
				$model set id $d
			}
			if {[set loc [expr {$count%$columnsize}]] in $functions } { 
				set fun [lindex $functions	[lsearch $functions $loc]+1]
				#	set fun [dict get $dictfunctions $loc]
				#	puts "Running function $fun for $d"
				set d [$model $fun $d]
			}
			lappend newvaluesdata $d
			incr count
		}
		set valuesdata $newvaluesdata
		unset newvaluesdata  functions  ;#locations

	}

	if {$makeAllLinks != 0} {	

		set link "view" 
		set query id
		#Set to 1 if nothing else as difference
		if {$makeAllLinks != 1} {
			ns_parseargs {{-location 1} -- link {query id}} $makeAllLinks
		} else {

			set location 1
		}
		#set location 1
		set count 1
		set vlength [llength $valuesdata]
		foreach d $valuesdata {
			set id [list [lindex $valuesdata [expr {($count-1)/$columnsize*$columnsize+$location-1}] ]]
			#	if {[expr {$count%$columnsize}]==$location} { 
			#		set id $d
		#	}
			lappend newvaluesdata [my link $d  $link "$query $id" ]
			#lappend newvaluesdata [my a $d  [ns_queryencode {*}$link $id] ]
			incr count
	}
	set valuesdata $newvaluesdata
	unset newvaluesdata
	}

	set varincr 0
	#This hides the first column usually the "id" column
	if {$hideFirstColumn} {
		set varincr 1
		dict set data columns  [lrange [dict get $data columns] 1 end]
		#	incr columnsize -1
	} 
	#If admin is on, you have multiple options..
	if {$search} { 
	#Add extra row before data
		foreach col [dict get $data columns] {
			set key [$model classKey $col]	
			lappend mydata  [my input -id $key $key ]  
		}
		if {$admin} {
			;#THIS is for the extra edit/admin column:) 
			lappend mydata   [my  input -type submit  -class "btn btn-primary" submit [mc "Search"]]  
		}
	}
	#lappend mydata   " "   ;#THIS is for the extra edit/admin column:) 
	#

	for {set var 0} {$var < $datasize } {incr var $columnsize} {
		set id [lindex $valuesdata $var]
		#TODO TEMPLATES

		#set view  [my a -class ""  "[my fa fa-eye] [mc View]" view/?id=$id]
		#set delete  [my a   "[my fa fa-trash-o ] [mc Delete]" delete?id=$id]
		#set edit  [my a   "[my fa fa-pencil] [mc Update]" update?id=$id]

		if {$admin} {
			set view  [my link  "[my fa fa-eye] [mc View]" view [list id $id]]
			set delete  [my link -new 1   "[my fa fa-trash-o ] [mc Delete]" delete [list id $id]]
			set edit  [my link   "[my fa fa-pencil] [mc Update]" update [list id $id]]

	set adminoptions [concat $view $edit $delete]
	#TODO add extra columns..
	#lappend mydata   [lrange $valuesdata $var [expr {$var+$columnsize-1}]] $admin   ] 
	#
	if {$rowId} {
	lappend mydata [format "%s %s {%s}" "-id $id"   [lrange $valuesdata [expr $var+$varincr] [expr {$var+$columnsize-1}]] $adminoptions   ] 
	} else {
	append mydata " " [format "%s {%s}"  [lrange $valuesdata [expr $var+$varincr] [expr {$var+$columnsize-1}]] $adminoptions   ] 
	}
	} else {
	if {$rowId} {
	lappend mydata [format "%s %s" "-id $id"  [lrange $valuesdata [expr $var+$varincr] [expr {$var+$columnsize-1}]]]
	} else {
	append mydata " " [lrange $valuesdata [expr $var+$varincr] [expr {$var+$columnsize-1}]]
	}
	}
	#lappend mydata  [lrange $valuesdata $var [expr {$var+$columnsize-1}]] "$view $edit $delete"  
	#set lasti $var
	}

	#	append mydata { 1 "Clinciu" "Andrei George" ending }
	# ns_puts "<br> data is $mydata this is columnsize $columnsize and [llength [dict get $data values]] long [dict size $data] <br>"
	#Table Header
	# with translation :)
	# TODO sorting descending or ascending:)
	if {$sort_type == "asc"} { set newsort_type "desc" } else { set newsort_type "asc" }
	foreach th [dict get $data columns] {
	lappend tablehead [format {-url 1  "%s" "%s" } [$model getAlias $th] \
		[ns_queryencode ${table}_sort $th	sort ${newsort_type}	${table}_page $page		${table}_perpage $perpage	{*}$extraUrlVars]]
	}
	if {$admin} {	 lappend tablehead [mc "Edit"] }
	set tablehtml [my table -class col-md-12 -bordered 1 -striped 1 -hover 1  -rpr $rowId   $tablehead   $mydata ]
	#set tablehtml [bootstrap::table -bordered 1 -striped 1 -hover 1 -rpr 0   [dict get $data columns ] [dict get $data values ] ]
	#
	set pagination [my pageGen -size $size -extraUrlVars $extraUrlVars $page $table $lastpage $perpage $sort $sort_type]	
	set divpagination [dict get $pagination divpagination]
	set pageinfo [dict get $pagination pageinfo]
	set perpagediv  [dict get $pagination perpagediv]

	set clearfix [my htmltag -htmlOptions [list class clearfix] div]
	set return [my htmltag -htmlOptions [list class $class] div "$divpagination  $pageinfo \n $clearfix  \n $extraData \n\n  $tablehtml  \n\n $divpagination $perpagediv  $clearfix"]
	return  $return
	}]
	}

	##########################################
	#  pageGen 
	##########################################
bhtml public method pageGen {{-extraUrlVars "" } {-size 0} --  page table lastpage perpage  sort sort_type } {
	set forFirstPage 1
	set forLastPage $lastpage
	if {$lastpage > 10} {
		set forFirstPage [expr {$page-5}] 
		set forLastPage [expr {$page+5}]
		if {$forFirstPage < 1} { set forFirstPage 1}
		if {$forLastPage > $lastpage} { set forLastPage $lastpage}
	}
	for {set var $forFirstPage} {$var <= $forLastPage } {incr var} {
		if {$var != $page} {
			lappend pagination "-url 1 $var	
			[ns_queryencode ${table}_page $var 	${table}_sort $sort 	${table}_perpage $perpage 	sort ${sort_type} 	{*}${extraUrlVars}]"
		} else { lappend pagination "-active 1 -url 1 $var #" }
	}
	set first [format {-url 1 "&laquo;" "%s" } \
		[ns_queryencode ${table}_page 1		${table}_sort $sort		${table}_perpage $perpage	sort ${sort_type}	{*}${extraUrlVars}]]
	set last [format {-url 1 "&raquo;" "%s" } \
		[ns_queryencode ${table}_page $lastpage		${table}_sort $sort		${table}_perpage $perpage 	sort ${sort_type}	{*}${extraUrlVars}]]  
	set htmlpagination [my pagination  -first $first -last $last   $pagination] 

	#TODO per page.. show it on/off.. +/- set the value incoming from the settings..
#	set perpage [bhtml htmltag -htmlOptions [list class "pull-right col-md-4"] p "Per page"]
#	set perpagediv [my label -class "col-md-3 control-label"  [mc "Per page"]]
	set perpagediv ""
	#TODO select the selected per page..
	#set selectdiv [bhtml select {5  5 10  {-selected 1 10} 25 25 50 50 100 100}]
	
	set selectdiv [my select -class "col-sm-4" -selected $perpage {5  5 10 10 25 25 50 50 100 100} ${table}_perpage]
	foreach {k v} $extraUrlVars {
		append selectdiv [my input -type hidden $k $v]
	}
	set gosubmit [my input  -type submit submit [mc "Per page"]]
	set perpageform [my form -action [ns_queryencode ${table}_page $page	${table}_sort $sort		{*}${extraUrlVars}]		"$selectdiv <br> $gosubmit"] 	
	append perpagediv " "  [my htmltag  -htmlOptions [list class [list col-sm-4 pull-right] style "max-width:110px;"] div  $perpageform ] ;#$selectdiv
	dict set return perpagediv [my htmltag  div $perpagediv]


	dict set return pageinfo <p>[mc "Per page %d, total %d.<br> Page %d from %d. "  $perpage $size $page $lastpage]</p>
	dict set return divpagination [my htmltag -htmlOptions [list  "class" "text-left col-md-8"] div  $htmlpagination   ]

#	dict set return divpagination $divpagination
#	dict set return pageinfo $pageinfo
#	dict set return perpagediv $perpagediv
	return $return
}

	##########################################
	#  detailview 
	# 		details about one view by just giving the name 
	# 		use this instead of generating it//
	##########################################
	 
bhtml public method detailView {{-table 1} --  model columns {specials ""}} {
	#Specials contains (for now) a list of column name and function
	#to run for that column name so we return the correct text..
	#TODO specials can be functions OR simple literals..
	##TODO in the future extract "col" from "columns" based on specials..
	#so we don't verify if col exists in specials 1000 times
	#
	#TODO specials for gridview!
	foreach col $columns {
		lappend tableheaders [$model getAlias $col]  
		if {$col in $specials} {
			set fun  [lindex $specials [lsearch $specials $col]+1]	
			lappend tabledata [$model $fun [$model get $col]]
		} else {
			lappend tabledata [$model get $col]
		}
	}
	if {$table} {
	
		set return  [my tableHorizontal -bordered 1 -striped 1 -hover 1 -rpr 0  $tableheaders $tabledata]
	}
	return $return
}	
	##########################################
	# TODO List View
	# 	giving a "view" location and make a list from it:)
	# 	or select a "view" from a detailview.. or something similair..
	##########################################
	#TODO take pagination and other stuff from gridView.. split gridView in multiple helper functions
bhtml public method  listView {{-perpage 10} {-page 1} {-sort id} {-sort_type asc} {-relations 0} {-toSelect *}  {-class ""} {-showTopPagination 0} 
							   -- view model {others ""}} {
	
	set pr_stmt ""	
	set table [$model getTable]
	set bhtml [self ]
#	set defSort "asc"
#	set allowedSort ""
#	set originalSort id
	if {[ns_queryexists ${table}_page]} { set page [ns_queryget ${table}_page 1] }
	if {[ns_queryexists ${table}_perpage]} { set perpage [ns_queryget ${table}_perpage 10] }
	#if {[ns_queryexists ${table}_sort]} { set sort [ns_queryget ${table}_sort $sort] }
	#if {![$model exists $sort]} { if {$sort ni $allowedSort} { set sort $originalSort } }
	#set sort_type [ns_queryget sort $defSort] 
	set ${table}_sort $sort

	#if {$externalData == 0} \{
	#set where_loc -1
	set where_loc [lsearch $others -where]
	set pr_stmt ""

	set where_sql ""
	#puts "Whereloc $where_loc"
	if {$where_loc != -1} {

	#	set where [lindex $others $where_loc+1]
		set first 0
		set where [lindex $others $where_loc+1]

		set computewhere [$model computeWhere $where $first 1] 
		append where_sql "WHERE "  [dict get $computewhere where_sql]
		set pr_stmt [dict merge $pr_stmt [dict get $computewhere pr_stmt]]

	}
#	puts  "$pr_stmt \"SELECT count(*) as size FROM $table  $where_sql;"

		dbi_1row  -db [$model db get ] -bind $pr_stmt "SELECT count(*) as size FROM $table  $where_sql;"
#	\}
	#	puts "Ok nigga hit'em $args $where_sql and count $size"
	if {$size == 0} { return [my htmltag div [msgcat::mc  "No data has been found, try adding something!" ]] }	
	#SELECT count(*)
	#	FROM information_schema.columns
	#	WHERE table_name = '<table_name>'

	#some verifications
	

	if {![string is integer $perpage]} { set perpage 10 }
	if {![string is integer $page]} { set page 1 }
	if {$perpage < 1} { set perpage 1 }
	if {$perpage > 100} { set perpage 100 }
	set lastpage [expr {int(ceil(double($size)/$perpage))}]
	
	#Verify if page isn't outside our borders
	if {$page < 1} { set page 1 } elseif {$page > $lastpage } { set page $lastpage }
	lappend others -offset [expr {$perpage*($page-1)}] -limit $perpage -order $sort -orderType $sort_type 

	#set other_get_opts "&{table}_sort=$sort&${table}_page=$page&${table}_perpage=$perpage&sort=${sort_type}"
	#puts "For data $others and $toSelect"
#	if {$externalData != 0} {
#		lappend others -selectSql [list $sql_select  $pr_stmt]
#	}
	#set data [$model search -relations $relations $toSearch]

	set data [$model search {*}[concat $others] $toSelect ]

	if {$data == ""} { return [mc "No data has been found, try adding something!"]}
	#puts "\n\n[dict get $data columns]\n"
	#TODO CACHE!
	#[lrange [dict get $data values]  [llength [dict get $data columns]] end]
	set columns [dict get $data columns]
#	set values [dict get $data values]
	foreach	$columns [dict get $data values]   {
		set m ""
		foreach v $columns {
			lappend m $v  $$v 
		#	$model set $v [subst $$v] 
		}
		#puts "ok for [subst $m]"
		$model set  {*}[subst $m]
		append page_data  [ns_adp_parse   -file $view.adp   bhtml $bhtml model $model  {*}$m]
	}
	if {0} {
	set forcache "$toSelect $perpage $page $sort $sort_type $admin $makeAllLinks $hideFirstColumn $extraUrlVars $specialFunctions $others"
	ns_parseargs {{-key ""} time}	$cache
	if {$key == ""} { 
		set key [::sha2::sha256 -hex $forcache]
	}
#	puts "Evaluating cache with key $key"
return	\[ns_cache_eval -timeout 5 -expires $time lostmvc $key  \{ 



	}
#-extraUrlVars $extraUrlVars
	set extraData ""
#	puts "ok $size $page $table $lastpage $perpage $sort $sort_type"
	set pagination [my pageGen -size $size $page $table $lastpage $perpage $sort $sort_type]	
	set divpagination [dict get $pagination divpagination]
	set pageinfo [dict get $pagination pageinfo]
	set perpagediv  [dict get $pagination perpagediv]
	
	set clearfix [my htmltag -htmlOptions [list class clearfix] div]
	#don't show to select how many to see per page..
	set perpagediv ""
	if {$showTopPagination == 1} {
	set showpagination "$divpagination  $pageinfo \n $clearfix  \n $extraData \n\n"
	} else  {
	set showpagination ""
	}
	set return [my htmltag -htmlOptions [list class $class] div "$showpagination  $page_data  \n\n $divpagination $perpagediv  $clearfix"]
	
#	return $page
}	
	
	##########################################
	# Datetimepicker addon 
	##########################################

bhtml public method datetimepicker {{-class ""} {-htmlOptions ""} {-format "YYYY-MM-DD HH:mm:ss"} {-id ""} {-moreSettings ""} {-placeholder ""} 
   {-popover ""} {-tooltip ""}  -- name {value ""}} {
	#TODO more settings

	if {![my existsPlugin datetimepicker]} {
		my addPlugin datetimepicker { 
			css "/css/bootstrap-datetimepicker.min.css"
			css-min "/css/bootstrap-datetimepicker.min.css"
			js  { "/js/moment.min.js" "/js/bootstrap-datetimepicker.min.js" }
			js-min  { "/js/moment.min.js" "/js/bootstrap-datetimepicker.min.js" }

		}
	}

	my js [format {
		$('#%s').datetimepicker({
			showToday:true,
			format: '%s',
			%s
		});
		//alert("Oooh yeah!");
	} $name $format $moreSettings ]
	#This works
	#set input [my input -htmlOptions [list data-provide "datepicker"] -id $name $name $value]
	
	set input [my input -placeholder $placeholder -id $name $name $value]
	set span [my htmltag -htmlOptions  [list class input-group-addon] span [my fa fa-calendar] ]

	dict set htmlOptions class "input-group date"
	set div [my htmltag -htmlOptions $htmlOptions div "$input $span"]
	return $div
}
	##########################################
	# Datepicker addon 
	##########################################

bhtml public method datepicker {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""}  -- name {value ""}} {

	if {![my existsPlugin datepicker]} {
		my addPlugin datepicker { 
			css "/css/datepicker3.css"
			css-min "/css/datepicker3.min.css"
			js "/js/bootstrap-datepicker.js"
			js-min "/js/bootstrap-datepicker.min.js"
		}
	}

	my js [format {
		$('#%s').datepicker({
			format: "yyyy-mm-dd",
			weekStart: 1,
			multidate: false,
			calendarWeeks: true,
			todayHighlight: true
		});
		//alert("Oooh yeah!");
	} $name ]
	#This works
	#set input [my input -htmlOptions [list data-provide "datepicker"] -id $name $name $value]
	set input [my input -placeholder $placeholder -id $name $name $value]
	set span [my htmltag -htmlOptions  [list class input-group-addon] span [my fa fa-calendar] ]

	set div [my htmltag -htmlOptions [list class [list input-group $class]] div "$input $span"]
	#set div [my htmltag div "$input $span"]
	return $div ;#$input
}
##########################################
# X-editable 
# url:  http://vitalets.github.io/x-editable/
# In place editing with jquery and bootstrap
##########################################

#TODO make it have more options..
bhtml public method editable {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""}  -- name {value ""}} {
	if {![my existsPlugin editable]} {
		my addPlugin editable { 
			css "/css/bootstrap-editable.css"
			css-min "/css/bootstrap-editable.min.css"
			js "/js/bootstrap-editable.js"
			js-min "/js/bootstrap-editable.min.js"
		}
	}

	my js [format { $('#%s').editable(); } $name ]
	set input [my a -id $name $value]
	return $input
}

##########################################
# Select2 (3.4.8) 
# url: http://ivaynberg.github.io/select2/  
# Replacement for select boxes, supports searching, remote data sets.. infinite scrolling of results.. etc
##########################################

#TODO make it have more options..
bhtml public method select2 {{-class ""} {-id ""} {-placeholder ""}  {-popover ""} {-tooltip ""} {-options ""}   -- name {value ""} {tags ""}} {
	#minimumInputLength: 2,
	#
	if {0} {
	query: function (query) {
		var data = {results: []};
		 data:[{id:0,text:'enhancement'},{id:1,text:'bug'},{id:2,text:'duplicate'},{id:3,text:'invalid'},{id:4,text:'wontfix'}]
	}
	}
	set plugin select2
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css { "/css/select2.css" "/css/select2-bootstrap.css"}
			css-min { "/css/select2.css" "/css/select2-bootstrap.css"}
			js "/js/select2.js"
			js-min "/js/select2.min.js"
		}
	}

	my js [format { $('#%s').select2({
		tags: [%s],
		multiple: true,
		tokenSeparators: [',','\t','\n',';'],
		width: 'resolve',
		%s
	}); } $name $tags $options ]
	set input [my input -class [concat "form-control " $class] -id $name -placeholder $placeholder $name $value]
	return $input
}

#This makes everything a little bit beautifuller..
##########################################
# PretyCheckable) 
# url: http://arthurgouveia.com/prettyCheckable/
# a beautiful checkbox
##########################################

bhtml public method prettycheckable {{-class ""} {-id ""} {-placeholder ""}   -- name data } {
#TODO implement more options
	set plugin prettycheckable
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css  "/css/prettyCheckable.css" 
			css-min  "/css/prettyCheckable.css" 
			js "/js/prettyCheckable.min.js"
			js-min "/js/prettyCheckable.min.js"
		}
	}

	my js [format { $('#%s').prettyCheckable({
		color: 'red',	
	}); } $name ]
	set input [my input -type checkbox -id $name $name $data]
	return $input
}


##########################################
# Bootstrap toggle! 
# url:  http://minhur.github.io/bootstrap-toggle/
# a beautiful toggle button
##########################################

#TODO make it have more options.. like primary type etc..
#Differfent types of buttons for on and off..etc
#not working yet.. port from earlier ersion
#TODO icon class for on or off.. otherwise size keeps growing..
bhtml public method toggle {{-class ""} {-id ""} {-placeholder ""} {-ontype "primary"} {-offtype "default"} \
			   {-onicon ""} {-officon ""} {-size ""} {-round 0} {-data 1}   -- on off name } {
	#This has some modifications from the original
	#The .js file is modified: alternating values 1 or 0

	set plugin toggle
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css  "/css/bootstrap-toggle.css" 
			css-min  "/css/bootstrap-toggle.min.css" 
			js "/js/bootstrap-toggle.js"
			js-min "/js/bootstrap-toggle.min.js"
		}
	}
	if {$data == ""} { set data 1 }

	if {$data} { set toggleon on } else { set toggleon off }

	set onlen [string length $on]
	set offlen [string length $off]
	if {$onicon != ""} { incr onlen 3  }
	if {$officon != ""} { incr offlen 3 }

 		if {$onlen>$offlen} {
			set thesize $onlen
		} else { set thesize $offlen }
		switch $size {
			mini { set size "btn-xs" ; set fontsize 4 }
			small { set size "btn-sm"  ; set fontsize 5.5 }
			large { set size "btn-lg" ; set fontsize 10 }
			default { set fontsize 7 }
		}
		set togglesize [expr {$thesize*$fontsize+35}]

set roundclass ""
if {$round} { set roundclass ios }
#	my js [format { } $name ]
	#This works
	set on  [my label -class "toggle-on btn btn-${ontype} $size $roundclass" "$onicon $on" ]
	set off [my label -class "toggle-off btn active btn-${offtype} $size $roundclass  " "$officon $off" ]
	set span [my htmltag -htmlOptions [list class [list toggle-handle btn btn-default $size $roundclass]] span] 
	set togglegroup [my htmltag -htmlOptions [list class "toggle-group"] div "$on $off $span"] 
	set input [my input -type checkbox -class "" -htmlOptions [list checked checked ] $name $data]
	set style "min-width: ${togglesize}px;" 
#	set style ""
	set class "toggle btn btn-primary  $size $roundclass $toggleon"
	set toggle [my htmltag -htmlOptions [list id $id class $class data-toggle toggle style $style ] div "$input $togglegroup"]
	


	return $toggle
}

##########################################
# CKEditor 
# url:  http://ckeditor.com/download
#  beautiful full featured html editor for blogs.. and any other things
##########################################

#TODO make it have more options..
bhtml public method ckeditor {{-class ""} {-placeholder ""} {-id ""}  -- name {data ""} } {

	set plugin ckeditor
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/ckeditor/ckeditor.js"
			js-min "/js/ckeditor/ckeditor.js"
		}
	}
	if {$id == ""} { set id $name }

	my js [format { CKEDITOR.replace('%s')  } $name ]
	set input [my textarea -placeholder $placeholder -id $id $name $data]
	return $input
}

##########################################
# Bootstrap markdown
# http://toopay.github.io/bootstrap-markdown/
# Markdown editor for places where you want users to be able to edit but
# don't trust the input and can't be 100% sure you won't have XSS
##########################################
bhtml public method markdown {{-class ""} {-placeholder ""} {-id ""}  -- name {data ""}} {
	if {![my existsPlugin  markdown]} {
		my  addPlugin markdown {
			js { "/js/to-markdown.js" "/js/bootstrap-markdown.js"  }
			js-min { "/js/to-markdown.js"  "/js/bootstrap-markdown.min.js" }
			css "/css/bootstrap-markdown.css"
			css-min "/css/bootstrap-markdown.min.css"
		}
	}
	if {$id == ""} { set id $name }

#	my js [format { CKEDITOR.replace('%s')  } $name ]
	my js [format {$("#%s").markdown({ resize:'both',iconlibrary: 'fa'})} $name]
	set input [my textarea -options [list data-provide markdown] -placeholder $placeholder -id $id $name $data]
	return $input
}

##########################################
# Bootstrap Image Gallery 
# url:   http://blueimp.github.io/Bootstrap-Image-Gallery/
#  A beautiful image gallery..
#http://blueimp.github.io/Gallery/css/blueimp-gallery.min.css
#http://blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js
##########################################

 bhtml public method imagegallery {{-class ""} {-borders true} {-tooltip ""}  {-thumbs 0} -- name {data ""}} {

 #TODO fullscreen and other options..
	set plugin imagegallery
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css { /css/blueimp-gallery.min.css "/css/bootstrap-image-gallery.min.css" }
			css-min { /css/blueimp-gallery.min.css "/css/bootstrap-image-gallery.min.css" }
			js { /js/jquery.blueimp-gallery.min.js "/js/bootstrap-image-gallery.min.js" }
			js-min { /js/jquery.blueimp-gallery.min.js "/js/bootstrap-image-gallery.min.js" }
		}
	}

	my js [format { 
		$('#blueimp-gallery').data('useBootstrapModal', %s );
		$('#blueimp-gallery').toggleClass('blueimp-gallery-controls', !%s); 
	} $borders $borders ]

		set imgOptions [list style "width:75px;height:75px;" ]

	foreach {imgsrc desc} $data {
		#TODO disable/enable tooltip automatically
		# TODO !!! TODO 	image should be a thumbnail..
		if {$thumbs} {
			foreach {img thumb} $imgsrc { }
		} else {
			set img [set thumb $imgsrc]
		}	
		if {$tooltip != ""} { foreach {opt val} [list data-toggle tooltip data-placement top title $desc]  { dict set imgOptions $opt $val } }
		set image [my img -htmlOptions $imgOptions  -class " img-thumbnail" $thumb $desc]
		set link [my a  -htmlOptions [list data-gallery ""] -title $desc $image $img ]
		append alldata $link
	}
	set gallery [my htmltag -htmlOptions [list class $name] div $alldata]	
	set blueimp {
	<!-- The Bootstrap Image Gallery lightbox, should be a child element of the document body -->
<div id="blueimp-gallery" class="blueimp-gallery">
    <!-- The container for the modal slides -->
    <div class="slides"></div>
    <!-- Controls for the borderless lightbox -->
    <h3 class="title"></h3>
    <a class="prev"> <span style="font-size:0.6em" class="fa fa-chevron-left"> </span></a>
    <a class="next"><i style="font-size:0.6em"  class="fa fa-chevron-right"> </i></a>
    <a class="close"><i class="fa fa-times"> </i></a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
    <!-- The modal dialog, which will be used to wrap the lightbox content -->
    <div class="modal fade">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" aria-hidden="true">&times;</button>
                    <h4 class="modal-title"></h4>
                </div>
                <div class="modal-body next"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default pull-left prev">
                        <i class="glyphicon glyphicon-chevron-left"></i>
                        Previous
                    </button>
                    <button type="button" class="btn btn-primary next">
                        Next
                        <i class="glyphicon glyphicon-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
	}
#	set blueimp [my htmltag -htmlOptions [list id "blueimp-gallery" class "blueimp-gallery blueimp-gallery-controls"] div $gallery]
	return "$gallery $blueimp"
}

#TODO implement pnofity or leave just this messenger?
##########################################
# HubSpot Messenger 
# # http://github.hubspot.com/messenger/
# Providing cool messages to user..
##########################################

bhtml public method messenger {{-type "info"} {-theme future} {-location "top"} {-button ""}  -- message } {
	#themes flat future block air ice	
#TODO make it have more options.. and implement all Messenger library options
#The first time you run this you give the settings..
#All subsequent runs .. go without:)
	set plugin messenger
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			css "/css/messenger.css"
			css-min "/css/messenger.css"
			js "/js/messenger.js"
			js-min "/js/messenger.min.js"
		}

		set messengertheme [format "/css/messenger-theme-%s.css" $theme]
		dict lappend plugins messenger css $messengertheme
		dict lappend plugins messenger css-min $messengertheme

		switch $theme {
			flat {
				dict lappend plugins messenger js "/js/messenger-theme-flat.js" 
				dict lappend plugins messenger js-min "/js/messenger-theme-flat.js" 
			}
			future { 
				dict lappend plugins messenger js "/js/messenger-theme-future.js"
				dict lappend plugins messenger js-min "/js/messenger-theme-future.js"
			}
		}

		foreach loc $location {
			switch $loc {
				top { set theloc "messenger-on-top" }
				bottom { set theloc "messenger-on-bottom" }
				left { set theloc "messenger-on-left" }
				right { set theloc "messenger-on-right" }
				default { set theloc "messenger-on-top messenger-on-right"}
			}

			lappend messengerLocation  $theloc 
		}
		my js [format {
			Messenger.options = {
				extraClasses: 'messenger-fixed %s',
				theme: '%s',
			}  
		} $messengerLocation $theme   ]
	#	puts "This messenger has been initializated.. with $messengerLocation and $theme"
	}
#todo make this only once..for the first one? or for each one?
	my js [format {
		Messenger().post({
			message: "%s",
			type: "%s",
			showCloseButton: true,
		});	
	}  $message $type ]
	
	#TODO figure out if returning anything.. or creating buttons.. etc
	if {$button != ""} {
		#set input [my textarea -placeholder $placeholder -id $name $name $data]
	#return $input
	}

}


##########################################
# HighCharts
# http://www.highcharts.com/demo/
# Generating charts and other things.. for statistics!
# Browser side but also server side saving:)
##########################################
#TODO this needs a lot of editing to include all options..
bhtml public method highcharts {{-slideOpen 0} {-height 400} {-text ""} -- name data } {

	#themes /js/themes/gray.js etc	

	set plugin highcharts
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/highcharts.src.js"
			js-min "/js/highcharts.js"
		}

	}
	set extra ""
	set container ""
	if {$text == ""} { set text $name } 
	if {$slideOpen} {
		append container  [my  a -htmlOptions "class tglchart-${name}"  "[my  fa fa-download] Click to toggle $text" "#$name" ]<br>

		append extra [format {
			$(".tglchart-%s").click(function(e) {
				e.preventDefault();
				$('#%s').slideToggle();
			});
	 	$('#%s').hide();	
		} $name $name  $name ]	
	}
	#TODO more options.. ok for now.. since this can be sent through ajax:)
	my js [format { 
		$('#%s').highcharts({
			credits: {
				href: "http://unitedbrainpower.com",
				text: "UnitedBrainPower.com",
				enabled: true,
			},
			%s
		});	 
		%s
	} $name $data $extra ]
	
	append container [my htmltag -htmlOptions  [list id $name style "width:100%; height:${height}px; "] div "" ]
	return $container

}

##########################################
# Bootstrap ContextMenu
#  http://sydcanem.github.io/bootstrap-contextmenu/
#  This generates a context (right click) menu in a website. THis can be used to do multiple usefull things
##########################################
#Figure out if you just need ID and generate the div itself or generate it outside..
 bhtml public method contextmenu {{-slideOpen 0} {-contextOptions ""} -- contextid menuname menu {contextdata ""}} {
	
	if {![my existsPlugin contextmenu]} {
			my addPlugin contextmenu { 
			js "/js/bootstrap-contextmenu.js"
			js-min "/js/bootstrap-contextmenu.min.js"
		}
		puts "This contextmenu doesn't already exist! [dict get $plugins contextmenu]"

	}
	
 	dict set contextOptions id $contextid
	dict set contextOptions data-toggle context
	dict set contextOptions data-target #${menuname}

	my js [format { 
	    $('#%s').contextmenu();
	} $contextid ]
	if {0} {
    <div id="context" data-toggle="context" data-target="#context-menu">
    ...
    </div>
	}
#	foreach m menu {
#		-htmlOptions tabindex -1
#	}
	#TODO extend method dropdown to generate more freely...
	set ul [my makeList -htmlOptions [list class dropdown-menu role menu] $menu ] 
	set contextmenu	 [my htmltag -htmlOptions [list id $menuname] div $ul]
	set context [my htmltag -htmlOptions $contextOptions div $contextdata]
	return "$context $contextmenu"

}


##########################################
# Bootstrap Slider
#  http://seiyria.github.io/bootstrap-slider/
#  Bootstrap slider for sliding selecting.. 
###########################################
bhtml public method slider {{-slideOpen 0} {-sliderid "allslider"} {-min 0} {-max 100 }  {-step 1} --  name {value 0} {secondval ""}} {

	set plugin slider
	if {![my existsPlugin $plugin]} {
		my addPlugin $plugin { 
			js "/js/bootstrap-slider.js"
			js-min "/js/bootstrap-slider.min.js"
			css "/css/bootstrap-slider.css"
			css-min "/css/bootstrap-slider.min.css"
		}

	}
	

	my js [format { 
	    $('#%s').slider({
		//	formater: function(value) {
		//		return "Current value: " + value
		//	}
		});
	} $name ]
	if {$secondval != ""} {
		set value \[${value},${secondval}\]
	}
	#ex1Slider .slider-selection {
	#	background: #BABABA;
		#}
 #for 2 selectors.. do the value [25,50]
 set slider_options [list id $name name $name data-slider-id $sliderid \
	 	data-slider-min $min data-slider-max $max data-slider-step $step data-slider-value $value ]
	set slider [my input -htmlOptions $slider_options  $name]
	return $slider 

}
##########################################
# jQuery Countdown 
#  https://github.com/Reflejo/jquery-countdown
# Beautiful countdown timer
# ###########################################
bhtml public method countdown {{-year ""} {-month ""} {-day ""} {-hour ""} -- name } {

	if {![my existsPlugin countdown]} {
		my addPlugin countdown { 
			js "/js/jquery.countdown.js"
			js-min "/js/jquery.countdown.min.js"
			css "/css/media.css"
			css-min "/css/media.css"
		}

	}
	if {$year == ""} {
		set year [clock format [clock seconds] -format %Y]	
	}
	if {$month == ""} {
	
		set month [clock format [clock seconds] -format %m]	
	}
	if {$day == ""} {
	
		set day [clock format [clock seconds] -format %d]	
	}
	if {$hour == ""} {
		set hour [clock format [clock seconds] -format %H]	
	}
	#TODO   body { background: url(../img/bg-tile.png) repeat; }
	my js [format { 
      $(function(){
        $("#%s").countdown({
          image: "img/digits.png",
          format: "dd:hh:mm:ss",
          endTime: new Date(%s, %s,%s,%s )
        });
      });
	} $name $year $month $day $hour ]
	set countdown [my tag -htmlOptions [list id $name]  div ""]
	return $countdown 

}
###############################################
#	jQuery Lazy image loading only when needed!
#	https://github.com/eisbehr-/jquery.lazy
#
###############################################
#FOR IMPLEMENTATION SEE Bhtml.tcl
##DO NOT USE THIS FUNCTION yet
#TODO needs modifying for other loading types
##Enable lazy loading for now.. if we modify html manually

bhtml public method lazyloader {args} {

	if {![my existsPlugin lazyload]} {
		my addPlugin lazyload { 
			js "/js/jquery.lazy.js"
			js-min "/js/jquery.lazy.min.js"
		}

		#delay: 5000 -> time in milliseconds that ALL images appear on page
		#combined :true -> loads on scroll and uses delay!
		##placeholder: data:image/jpg/gif base64
		# enable throttle so you  have less javascript calls!
		#enableThrottle: true
		#throttle: 250 
		:js "jQuery('img.lazy').lazy();"
		

	}

	#set img [:img {*}$args]
	#return $countdown 

}

##########################################
# Bootstrap Wizard manual
#  http://yiibooster.clevertech.biz/widgets/grouping/view/wizard.html
#  A wizard with tabs and pills 
###########################################
#TODO pager buttons next previous to go to tab..
#TODO horizontal and vertical
bhtml public method wizard { {-step 1} -- tabs } {

set wizard [my tabs -pills 1 $tabs][my pager ] 
	return $wizard 

}
#TODO download and implement
##########################################
# Bootstrap Wizard 
# http://vadimg.com/twitter-bootstrap-wizard-example/
#  A wizard with navigation and next/previous 
###########################################
bhtml public method wizard {{-step 1} -- tabs} {


	if {![my existsPlugin wizard]} {
		my addPlugin wizard { 
		}
	}
	

#	my js [format { 

#	} $name ]

	#ex1Slider .slider-selection {
	#	background: #BABABA;
		#}
 #for 2 selectors.. do the value [25,50]
# set slider_options [list id $name name $name data-slider-id $sliderid \
#	 	data-slider-min $min data-slider-max $max data-slider-step $step data-slider-value $value ]
	set wizard [my tabs -pills 1 $tabs][my pager ] 
	return $wizard 

}

#TODO really, this is very important
##########################################
#TODO bootstro.js
#http://clu3.github.io/bootstro.js/#
# http://usablica.github.io/intro.js/   or use intro.js ? 
#Making presentations of your application or showing users how to do some things!
##########################################



##########################################
# TODO Eldarion AJAX sending ajax etc
#https://github.com/eldarion/eldarion-ajax/
##########################################


##########################################
# Syntax Highlight
#http://alexgorbatchev.com/SyntaxHighlighter/download/
##########################################
bhtml public method syntaxHighlighter {args} {

	#ns_parseargs {   } $args
	if {![my existsPlugin syntaxhighlighter]} {
		my addPlugin syntaxhighlighter { 
			js { /js/sh/shCore.js /js/sh/shAutoloader.js }
			js-min { /js/sh/shCore.js /js/sh/shAutoloader.js }
			css { /css/sh/shCore.css /css/sh/shCoreMidnight.css }
			css-min { /css/sh/shCore.css /css/sh/shCoreMidnight.css }
		}

	}
	

	my js [format { 
	/*	SyntaxHighlighter.autoloader(
			'js jscript javascript /js/sh/shBrushJScript.js',
			'bash /js/sh/shBrushBash.js'
		);*/
		   function brushpath()
      {
        var args = arguments,
            result = []
            ;
             
        for(var i = 0; i < args.length; i++)
            result.push(args[i].replace('@', '/js/sh/'));
             
        return result
      };
       
      SyntaxHighlighter.autoloader.apply(null, brushpath(
        'applescript            @shBrushAppleScript.js',
        'actionscript3 as3      @shBrushAS3.js',
        'bash shell             @shBrushBash.js',
        'coldfusion cf          @shBrushColdFusion.js',
        'cpp c                  @shBrushCpp.js',
        'c# c-sharp csharp      @shBrushCSharp.js',
        'css                    @shBrushCss.js',
        'delphi pascal          @shBrushDelphi.js',
        'diff patch pas         @shBrushDiff.js',
        'erl erlang             @shBrushErlang.js',
        'groovy                 @shBrushGroovy.js',
        'java                   @shBrushJava.js',
        'jfx javafx             @shBrushJavaFX.js',
        'js jscript javascript  @shBrushJScript.js',
        'perl pl                @shBrushPerl.js',
        'php                    @shBrushPhp.js',
        'text plain             @shBrushPlain.js',
        'py python              @shBrushPython.js',
        'ruby rails ror rb      @shBrushRuby.js',
        'sass scss              @shBrushSass.js',
        'scala                  @shBrushScala.js',
        'sql                    @shBrushSql.js',
        'vb vbnet               @shBrushVb.js',
        'xml xhtml xslt html    @shBrushXml.js'
      ));
		SyntaxHighlighter.all();
	} "" ]

}




##########################################
#TODO Bootstrap acknowledge inputs
# http://averagemarcus.github.io/Bootstrap-AcknowledgeInputs/
# Give user visual feedback on the page..
##########################################

##########################################
# Tag Cloud 
# 	Create a visual Tag Cloud
# 	Needs 1 variable tagCloud that is a dictionary containing
# 	columnNames (id tag count) and all the values
#
# 	Returns the HTML tag Cloud
##########################################
	#Generate HTML tag cloud..
	#TODO externalize in bhtml..?
bhtml public method genTagCloud {tagCloud {controller ""}} {
	set font_min 7
	set font_max 40
	set increment [expr {($font_max-$font_min)/10}]
	set result ""
	set values [dict get  $tagCloud values]
	set current_size $font_min
	#ns_parseargs {{-controller ""} {-url 1} -- text action {query ""}} $args
	foreach {id tag count} $values {
		set link [my link -controller $controller $tag tag [list tag $tag] ]
		set current_size [expr {$font_min+$increment*$count}]
		if {$current_size > $font_max} {
			if {$current_size > [expr {$font_max *3/2}]} {
				set current_size [expr {$font_max+log($count)*2}]	
			} else {
				set current_size [expr {int($font_max+($increment*$count)*0.1)}]
			}
		}  
		set textsize "font-size: ${current_size}px;"
		append result [my htmltag -htmlOptions [list style  "padding-right: 5px;$textsize display:inline-block;"] div $link  ]
	}
	#		set result [$bhtml htmltag -htmlOptions [list class col-xs-12] div $result]
	return $result
}
#A second more 'fine graiend" tag cloud generator.. for values higher and higher..
bhtml public method genTagCloud2 {tagCloud {controller ""}} {
	set font_min 6
	set font_max 40
	set increment [expr {($font_max-$font_min)/1000.}]
	set result ""
	set values [dict get  $tagCloud values]
	set current_size $font_min
	#ns_parseargs {{-controller ""} {-url 1} -- text action {query ""}} $args
	foreach {id tag count total} $values {
		set link [my link -controller $controller $tag tag [list tag $tag] ]
		set current_size [expr {$font_min+$increment*$total}]
		if {$current_size > $font_max} {
			if {$current_size > [expr {$font_max *3/2}]} {
				set current_size [expr {$font_max+log($total)*2}]	
			} else {
				set current_size [expr {int($font_max+($increment*$total)*0.1)}]
			}
		}  
		set textsize "font-size: ${current_size}px;"
		append result [my htmltag -htmlOptions [list style  "padding-right: 5px;$textsize display:inline-block;"] div $link  ]
	}
	#		set result [$bhtml htmltag -htmlOptions [list class col-xs-12] div $result]
	return $result
}

