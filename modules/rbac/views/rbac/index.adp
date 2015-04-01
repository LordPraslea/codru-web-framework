
<%

set title [mc "RBAC - Role Based Access Control Admin"]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-url 1 {[mc RBAC]} /rbac/}
			{-active 1 $title }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc {Role Item}]} [my getUrl -controller roleitem create]}
	{  -url 1   {[mc Create] [mc {Role Item Child}]} [my getUrl -controller roleitemchild create]}
	{  -url 1   {[mc {Assign Role}]} [my getUrl -controller roleassignment create]}
	{  -url 1 -show 0   {[mc Admin] [mc RoleItem]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

set h1 [$bhtml htmltag h1 "Role Items"]
set data [$bhtml gridView -specialFunctions "type getType" $model   ]

set panel [$bhtml panel  -h $h1 $data]

ns_puts "<div class='col-lg-12'>$panel</div>"
set h1 [$bhtml htmltag h1 "Role Item Children"]
set ricmodel [RoleItemChild new]
set data [$bhtml gridView -sort "parent_id" -externalData [$ricmodel getItems] $ricmodel]
set panel [$bhtml panel  -h $h1 $data]
ns_puts "<div class='col-lg-6'>$panel</div>"

set h1 [$bhtml htmltag h1 "Role Assignments"]
set ramodel [RoleAssignment new]
set data [$bhtml gridView -sort user_id -toSelect "user item" $ramodel  [list -relations 1]  ]
set panel [$bhtml panel  -h $h1 $data]
ns_puts "<div class='col-lg-6'>$panel</div>"
%>


