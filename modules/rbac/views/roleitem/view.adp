

<%

set title [mc "View RoleItem [$model get name ] "]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mcRBAC]} /rbac/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc RoleItem]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc RoleItem]} [my getUrl update [list id $id]]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {id name type description bizrule data}]

%>


