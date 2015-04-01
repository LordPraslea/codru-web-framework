

<%

set title [mc "Index of %s" [mc RoleAssignment]]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc RoleAssignment]} /roleassignment/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleAssignment]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleAssignment]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc RoleAssignment]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc RoleAssignment]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc RoleAssignment]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {item_id user_id bizrule data}]

%>


