
<%

$bhtml syntaxHighlighter 
if {![info exists title]} {
set title [mc "United Brain Power Blog"]
}

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-url 1  {[mc Blog]} /blog/ }
		"

dict set pageinfo menu "
		{ }
	{  -url 1 -show [my hasRole adminPost]  {[mc Create] [mc Post]} [my getUrl create]}
	{  -url 1 -show [my hasRole adminPost]   {[mc Admin] [mc Post]} [my getUrl -controller cms admin]}
	{  -url 1 -show [my hasRole adminPost]   {[mc Admin] [mc Comments]} [my getUrl -controller comment index]}
"

dict set pageinfo sidebar  [ns_adp_parse -file sidebar.adp   $model $bhtml]
dict set pageinfo author "United Brain Power"
dict set pageinfo description "United Brain Power Blog"
ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}
ns_puts <hr>
#ns_puts [$bhtml gridView -toSelect "id title slug post author author_id creation_at" $model [list -relations 1] ]
set toSelect "id title slug post author author_id creation_at public_at status reading_time"
#set where [list -cond AND status 1]
#set where ""
set allowedStatus [list 1 3 4 5]
if {[my verifyAuth]} { lappend allowedStatus 2}
lappend where [list -cond IN status $allowedStatus]
lappend where [list -eq <= public_at [getTimestamp] ]
lappend where [list cms 0 ]
lappend options -relations 1 -where $where
ns_puts [$bhtml listView  -perpage 5 -sort public_at -sort_type desc \
	-toSelect $toSelect  _view $model $options ]
%>


