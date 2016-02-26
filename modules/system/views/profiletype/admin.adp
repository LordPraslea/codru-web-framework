

<%

set title [mc "Admin page for %s" [mc ProfileType]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc ProfileType]} /profiletype/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc ProfileType]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc ProfileType]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}
set gridView [GridView new -search 1 -admin 1 -model $model -bhtml $bhtml ]
ns_puts [$gridView getGridView ]

%>


