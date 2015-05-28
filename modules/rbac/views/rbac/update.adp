
<%

#Include page title
dict set pageinfo title "[mc Updating] [mc RoleItem] with id [$model get id]"
#Breadcrumbs include
		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {#}}

			{-url 1 {[mc {RBAC}]} /rbac/}
			{-url 1 {[mc {Role Item}]} /roleitem/index}
			{-active 1 [dict get $pageinfo title]\}
		"  

	set id [$model get id]
	set modelname "Role Item"
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc $modelname]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc $modelname]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc $modelname]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc $modelname]} [my getUrl admin]}
"


ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
#Eventually pass the $model ?
ns_puts [ns_adp_parse -file form.adp ]

%>
