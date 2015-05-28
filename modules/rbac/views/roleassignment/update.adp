<%

#Include page title
dict set pageinfo title [mc "Updating Role Assignment [$model get item] -> [$model get user]"]
#Breadcrumbs include
		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {/}}

			{-url 1 {[mc {RBAC}]} /rbac/}
			{-url 1 {[mc {Role Assignment}]} /roleassignment/index}
			{-active 1 [dict get $pageinfo title]\}
		"  

	set item_id [$model get item_id]
	set user_id [$model get user_id]
dict set pageinfo menu "
	{  -url 1   {[mc {Delete Role Assignment  }]} [my getUrl delete [list item_id $item_id user_id $user_id]]}
"


ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
#Eventually pass the $model ?
ns_puts [ns_adp_parse -file form.adp ]

%>
