
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

dict set pageinfo menu " "

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
set c [SQLCriteria new -model $model]
set allowedStatus [list 1 3 4 5]
if {[my verifyAuth]} { lappend allowedStatus 2}
$c add -fun IN status $allowedStatus
$c add -op <= public_at [getTimestamp] 
$c add cms 0 

$model bhtml $bhtml
lappend options -relations 1 -criteria $c
set listview [ListView new  -perpage 5 -sort public_at -sort_type desc \
	-toSelect $toSelect  -view _view -bhtml $bhtml -model $model -searchOptions $options ]
ns_puts [$listview getListView]
%>


