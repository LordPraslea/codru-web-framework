

<%

set title [mc "Admin page for %s" [mc Post]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc Blog]} /blog/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc Post]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc Post]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}

set toSelect "id title  creation_at author language status cms"
set gridView [GridView new -searchBar 1 -admin 1 -hideFirstColumn 1 -bhtml $bhtml -rowId 1  \
	-specialFunctions [list post showHtml status status] -toSelect $toSelect -model $model -searchOptions [list -relations 1] ]
ns_puts [$gridView getGridView]
%>


