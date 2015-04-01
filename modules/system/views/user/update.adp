

<%
dict set pageinfo title "[mc Updating] [mc User] with id [$model get id]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {/}}
			{-url 1 {[mc User]} /user/index}
			{-active 1 \"[mc Updating] User [$model get id]\"}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc User]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc User]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc User]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc User]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 "[mc Update] User"]
ns_puts [ns_adp_parse -file form.adp ]
%>


