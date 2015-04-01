<%
dict set pageinfo title "[mc Updating] [mc User]  [$model get username]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {/index}}
			{-url 1 {[mc User]} /user/profile}
			{-active 1 [dict get $pageinfo title]}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc Profile] } [my getUrl profile]}
	{  -url 1 -show 0   {[mc Admin] [mc User]} [my getUrl admin]}
"
	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}
ns_puts [$bhtml htmltag h1 [dict get $pageinfo title]]
ns_puts [ns_adp_parse -file profileform.adp ]
%>


