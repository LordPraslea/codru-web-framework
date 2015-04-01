

<%
dict set pageinfo title "[mc Updating] [mc UserProfile] with id [$model get id]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {#}}
			{-url 1 {[mc UserProfile]} /userprofile/index}
			{-active 1 \"[mc Updating] UserProfile [$model get id]\"}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc UserProfile]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc UserProfile]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc UserProfile]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc UserProfile]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 "[mc Update] UserProfile"]
ns_puts [ns_adp_parse -file form.adp ]
%>


