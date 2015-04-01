
<%
dict set pageinfo title "Profile of [$model get username]"

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/index"}
			{-url 1 {[mc User]} /user/profile}
			{-active 1  [dict get $pageinfo title]}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc View Profile] [mc User]} [my getUrl profile]}
	{  -url 1   {[mc Update] [mc profile]} [my getUrl profileUpdate ]}
"

ns_puts [$bhtml htmltag h1 [dict get $pageinfo title ]]

ns_puts [$bhtml detailView $model  {id username  email last_login_at creation_at status }]
set upmodel [UserProfile new]
ns_puts [$bhtml gridView -sort user_id  -toSelect [list  profile profile_value] $upmodel [list -relations 1]  ]

%>


