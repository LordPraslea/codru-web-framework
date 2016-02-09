

<%

set title [mc "Admin page for %s" [mc User]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc User]} /user/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc User]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc User]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}


	set gridView [GridView new -searchBar 1 -admin 1  -model $model -bhtml $bhtml \
	-toSelect [list username email last_login_at creation_at status user_type]]
ns_puts [$gridView getGridView  ]
%>


