
<%

set title [mc "Index of %s" [mc User]]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-active 1 {[mc User]} }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc User]} [my getUrl create]}
	{  -url 1 -show 0   {[mc Admin] [mc User]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]

set gridView [GridView new  -toSelect [list username email last_login_at creation_at status user_type] -bhtml $bhtml -model $model ]
ns_puts [$gridView getGridView]
%>


