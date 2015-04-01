
<%

set title [mc "Index of %s" [mc UserProfile]]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-active 1 {[mc UserProfile]} }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc UserProfile]} [my getUrl create]}
	{  -url 1 -show 0   {[mc Admin] [mc UserProfile]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [$bhtml gridView -sort profile_id $model ]
%>


