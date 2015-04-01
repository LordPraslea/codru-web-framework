

<%

set title [mc "Admin page for %s" [mc RoleItemChild]]
dict set pageinfo title $title 


	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc RoleItemChild]} /roleitemchild/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItemChild]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleItemChild]} [my getUrl create]}
"

ns_puts [$bhtml htmltag h1 $title]

	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}

ns_puts [$bhtml gridView -search 1 -admin 1 $model ]
%>


