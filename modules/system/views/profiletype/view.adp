

<%
dict set pageinfo title "Viewing  [mc ProfileType] [$model get id]"

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc ProfileType]} /profiletype/index}
			{-active 1 "Viewing ProfileType #[$model get id]"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc ProfileType]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc ProfileType]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc ProfileType]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc ProfileType]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc ProfileType]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 [dict get $pageinfo title ]]

	ns_puts [$bhtml detailView $model  {id name type required}]

%>


