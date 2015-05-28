

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
"

ns_puts [$bhtml htmltag h1 "[dict get $pageinfo title]"]
ns_puts [ns_adp_parse -file form.adp ]
%>


