

<%
dict set pageinfo title "Viewing  [mc UserProfile] [$model get id]"

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc UserProfile]} /userprofile/index}
			{-active 1 "Viewing UserProfile #[$model get id]"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc UserProfile]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc UserProfile]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc UserProfile]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc UserProfile]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc UserProfile]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 [dict get $pageinfo title ]]

	ns_puts [$bhtml detailView $model  {user_id profile_id profile_value}]

%>


