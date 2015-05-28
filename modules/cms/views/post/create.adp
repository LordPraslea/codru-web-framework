
<%

set title [mc "Creating new %s" [mc Post]]
dict set pageinfo title $title


	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} \"#\"}
			{-url 1 {[mc Blog]}  /blog/index }
			{-active 1 $title  }
	"
dict set pageinfo menu " "

ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file form.adp ]
%>


