

<%

set title [mc "Admin page for %s" [mc RoleItem]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc RoleItem]} /roleitem/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItem]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleItem]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}

ns_puts [$bhtml gridView -search 1 -admin 1 $model ]
%>


