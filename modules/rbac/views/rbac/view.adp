

<%

set title [mc "Index of %s" [mc RoleItem]]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc RoleItem]} /roleitem/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItem]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc RoleItem]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc RoleItem]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc RoleItem]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc RoleItem]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {id name type description bizrule data}]

%>


