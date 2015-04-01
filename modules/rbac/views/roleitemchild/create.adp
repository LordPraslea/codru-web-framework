
<%

set title [mc "Creating new %s" [mc RoleItemChild]]
dict set pageinfo title $title


	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc RoleItemChild]}  /roleitemchild/index }
			{-active 1 $title  }
	"
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc RoleItemChild]} [my getUrl index]}
	{  -url 1 -show 0   {[mc Admin] [mc RoleItemChild]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file form.adp ]
%>


