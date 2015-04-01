
<%

set title [mc "Index of %s" [mc RoleItem]]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-url 1 {[mc RBAC]} /rbac/}
			{-active 1 {[mc RoleItem]} }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc {Role Item}]} [my getUrl -controller roleitem create]}
	{  -url 1   {[mc Create] [mc {Role Item Child}]} [my getUrl -controller roleitemchild create]}
	{  -url 1   {[mc {Assign Role}]} [my getUrl -controller roleassignment create]}
	{  -url 1 -show 0   {[mc Admin] [mc RoleItem]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [$bhtml gridView -specialFunctions "type getType" $model   ]
%>


