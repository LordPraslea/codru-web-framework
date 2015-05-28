

<%

	set id [$model get id]
set title [mc "RoleItem [$model get name] "]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc RBAC]} /rbac/index}
			{-active 1 "$title"}
	} ]  
dict set pageinfo menu "
		{ -url 0 Role Item Settings: }
	{  -url 1   {[mc Update] [mc RoleItem]} [my getUrl -controller roleitem update [list id $id]]}
	{  -url 1   {[mc Delete] [mc RoleItem]} [my getUrl -controller roleitem  delete [list id $id]]}
"

ns_puts [$bhtml htmltag h1 $title]

ns_puts [$bhtml detailView $model  {id name type description bizrule data}]

%>


