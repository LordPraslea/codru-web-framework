
<%
 set title [mc "Register - Create a new user"]
dict set pageinfo title $title 
dict set pageinfo breadcrumb "
			{-url 1 [mc Home] /}
			{-active 1 $title }
		"
ns_puts [$bhtml htmltag h1 $title]
ns_puts [ns_adp_parse -file registerform.adp ]
%>


