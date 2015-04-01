

<%

set title [mc "Admin page for %s" [mc RoleAssignment]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc RoleAssignment]} /roleassignment/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleAssignment]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleAssignment]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}

ns_puts [$bhtml gridView -search 1 -admin 1 $model ]
%>


