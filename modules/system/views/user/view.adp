

<%
dict set pageinfo title "Viewing  [mc User] [$model get username]"

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc User]} /user/index}
			{-active 1 "Viewing User #[$model get username]"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc User]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc User]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc User]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc User]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc User]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 [dict get $pageinfo title ]]

ns_puts [$bhtml detailView $model  {id username  email last_login_at creation_at status }]
ns_puts [$bhtml detailView $model  {id username password  email last_login_at 
									creation_at activation_code status password_reset_at password_code
									creation_ip login_attempts temp_login_block_until}]

%>


