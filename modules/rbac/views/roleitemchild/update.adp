
<%

#Include page title
dict set pageinfo title [mc "Updating RoleItemChild [$model get parent] -> [$model get child]"]
#Breadcrumbs include
		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {/}}

			{-url 1 {[mc {RBAC}]} /rbac/}
			{-url 1 {[mc {Role Item Child}]} /roleitemchild/index}
			{-active 1 [dict get $pageinfo title]\}
		"  

	set child_id [$model get child_id]
	set parent_id [$model get parent_id]
dict set pageinfo menu "
	{  -url 1   {[mc {Delete Role Item Child }]} [my getUrl delete [list child_id $child_id parent_id $parent_id]]}
"


ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
#Eventually pass the $model ?
ns_puts [ns_adp_parse -file form.adp ]

%>
