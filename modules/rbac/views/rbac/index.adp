<%
set title [mc "RBAC - Role Based Access Control Admin"]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} /}
			{-url 1 {[mc RBAC]} /rbac/}
			{-active 1 $title }
		"

dict set pageinfo menu " "

ns_puts [$bhtml htmltag h1 $title]

set h1 [$bhtml htmltag h1 "Role Items"]
set gridView [GridView new -makeAllLinks 1 -hideFirstColumn 1 -specialFunctions "type getType" \
		-model $model -bhtml $bhtml  -toSelect "id name description type "  ]
set data [$gridView getGridView]
set panel [$bhtml panel  -h $h1 $data]

ns_puts "<div class='col-lg-12'>$panel</div>"
set h1 [$bhtml htmltag h1 "Role Item Children"]
set ricmodel [RoleItemChild new]
set gridView [GridView new  -sort "parent_id" -specialFunctions "options makeViewLink "  \
	-externalData [$ricmodel getItems] -model $ricmodel -bhtml $bhtml]
set data [$gridView getGridView]
set panel [$bhtml panel  -h $h1 $data]
ns_puts "<div class='col-lg-10'>$panel</div>"

set h1 [$bhtml htmltag h1 "Role Assignments"]
set ramodel [RoleAssignment new]
set gridView [GridView new -sort user_id -toSelect "user_id user item_id item options"  -specialFunctions "options makeViewLink " -model $ramodel \
	-searchOptions [list -relations 1] -bhtml $bhtml  ]
set data [$gridView getGridView]
set panel [$bhtml panel  -h $h1 $data]
ns_puts "<div class='col-lg-10'>$panel</div>"
%>

