

<%
dict set pageinfo title "[mc Updating] [mc ProfileType] with id [$model get id]"

		dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {#}}
			{-url 1 {[mc ProfileType]} /profiletype/index}
			{-active 1 \"[mc Updating] ProfileType [$model get id]\"}
		"  

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc ProfileType]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc ProfileType]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc ProfileType]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc ProfileType]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 "[mc Update] ProfileType"]
ns_puts [ns_adp_parse -file form.adp ]
%>


