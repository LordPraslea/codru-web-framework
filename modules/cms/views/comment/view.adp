

<%

set title [mc "Index of %s" [mc Comment]]

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc Comment]} /comment/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc Comment]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc Comment]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc Comment]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc Comment]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc Comment]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

	ns_puts [$bhtml detailView $model  {id reply_to post_id comment creation_at user_id status}]

%>


