

<%
dict set pageinfo title "[mc Updating] [mc Post]  [$model get title]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {#}}
			{-url 1 {[mc Blog]} /blog/index}
			{-active 1 [dict get $pageinfo title]}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc Preview] [mc Post]} [my getUrl -controller blog  [$model get slug]]}
	{  -url 1   {[mc List] [mc Post]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc Post]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc Post]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc Post]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
ns_puts [ns_adp_parse -file form.adp ]
%>


