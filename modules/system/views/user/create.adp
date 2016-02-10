
<%

set title [mc "Creating new %s" [mc User]]
dict set pageinfo title $title


	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} /index }
			{-url 1 {[mc User]}  /user/index }
			{-active 1 $title  }
	"
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc User]} [my getUrl index]}
	{  -url 1 -show 0   {[mc Admin] [mc User]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file createnewaccount.adp ]
%>


