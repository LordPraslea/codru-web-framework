
<%

set title [mc "Index of %s" [mc ProfileType]]

dict set pageinfo title $title 

	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} #}
			{-active 1 {[mc ProfileType]} }
		"

dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc ProfileType]} [my getUrl create]}
	{  -url 1 -show 0   {[mc Admin] [mc ProfileType]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [$bhtml gridView -makeAllLinks [list update] $model ]
%>


