
<%

set title [mc "Creating new %s" [mc ProfileType]]
dict set pageinfo title $title


	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc ProfileType]}  /profiletype/index }
			{-active 1 $title  }
	"
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc ProfileType]} [my getUrl index]}
	{  -url 1 -show 0   {[mc Admin] [mc ProfileType]} [my getUrl admin]}
"

ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file form.adp ]
%>


