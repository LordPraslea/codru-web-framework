
<%

set title [mc "Comments"]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-active 1 {[mc Comment]} }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc Comment]} [my getUrl create]}
	{  -url 1 -show 0   {[mc Admin] [mc Comment]} [my getUrl admin]}
"


ns_puts [$bhtml tag h1 "Comments requiring approval"]
set where [list status 0]
ns_puts [$bhtml gridView -admin 1 -hideFirstColumn 1 -specialFunctions "status genStatus" \
	-toSelect [list id reply_to post  comment creation_at user status ] \
		$model   [list -relations 1 -where $where] ]

	ns_puts [$bhtml tag h1 "All comments!"]
ns_puts [$bhtml gridView -admin 1 -hideFirstColumn 1 -specialFunctions "status genStatus" \
	-toSelect [list id reply_to post  comment creation_at user status ] \
		$model   [list -relations 1  ]] 

%>


