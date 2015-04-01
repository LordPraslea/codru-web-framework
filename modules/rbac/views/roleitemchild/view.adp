

<%

set title [mc "Index of %s" [mc RoleItemChild]]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc RoleItemChild]} /roleitemchild/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItemChild]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleItemChild]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc RoleItemChild]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc RoleItemChild]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc RoleItemChild]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {parent_id child_id}]

%>


