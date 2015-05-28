

<%
	set child_id [$model get child_id]
	set parent_id [$model get parent_id]
set title [mc "RoleItemChild "]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc RBAC]} "/rbac/"}
			{-url 1 {[mc RoleItemChild]} /roleitemchild/index}
			{-active 1 "$title"}
	} ]  
d]
dict set pageinfo menu "
	{  -url 1   {[mc {Delete Role Item Child }]} [my getUrl delete [list child_id $child_id parent_id $parent_id]]}
	{  -url 1   {[mc {Update Role Item Child }]} [my getUrl update [list child_id $child_id parent_id $parent_id]]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {parent child}]

%>


