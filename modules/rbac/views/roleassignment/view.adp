

<%
	set item_id [$model get item_id]
	set user_id [$model get user_id]
set title [mc "Role Assignment "]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc Rbac]} "/rbac/"}
			{-url 1 {[mc RoleAssignment]} /roleassignment/index}
			{-active 1 "$title"}
	} ]  

dict set pageinfo menu "
	{  -url 1   {[mc {Delete Role Assignment  }]} [my getUrl delete [list item_id $item_id user_id $user_id]]}
	{  -url 1   {[mc {Update Role Assignment  }]} [my getUrl update [list item_id $item_id user_id $user_id]]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {item user bizrule data}]

%>


