
<%

set title [mc "Creating new %s" [mc RoleItem]]
dict set pageinfo title $title


	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc RoleItem]}  /roleitem/index }
			{-active 1 $title  }
	"
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItem]} [my getUrl index]}
	{  -url 1 -show 0   {[mc Admin] [mc RoleItem]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file form.adp ]
%>


