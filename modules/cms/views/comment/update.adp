

<%
dict set pageinfo title "[mc Updating] [mc Comment] with id [$model get id]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {#}}
			{-url 1 {[mc Comment]} /comment/index}
			{-active 1 [dict get $pageinfo title]}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc Comment]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc Comment]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc Comment]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc Comment]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
ns_puts [ns_adp_parse -file form.adp ]
%>


