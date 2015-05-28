
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
set criteria [SQLCriteria new -model $model]
$criteria add status 0
set gridView [GridView new  -admin 1 -hideFirstColumn 1 -specialFunctions "status genStatus" \
	-toSelect [list id reply_to post  comment creation_at user status ] \
	-model	$model  -bhtml $bhtml -searchOptions [list -relations 1 -criteria $criteria] ]
ns_puts [$gridView getGridView]

	ns_puts [$bhtml tag h1 "All comments!"]
set gridView [GridView new -admin 1 -hideFirstColumn 1 -specialFunctions "status genStatus" \
	-toSelect [list id reply_to post  comment creation_at user status ] \
	-bhtml $bhtml -model	$model  -searchOptions [list -relations 1  ]] 

ns_puts [$gridView getGridView]
%>


