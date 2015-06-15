<%
	#This generates our beloved index page..
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"
#Include page title
ns_puts [format {
set title [mc "Index of %%s" [mc %s]]

dict set pageinfo title $title } $modelname]

#Breadcrumbs include
ns_puts [format {
	dict set pageinfo breadcrumb "
			{-url 1 {[mc Home]} /}
			{-active 1 {[mc %s]} }
		"} $modelname] 
#Include MENU for buttons.. etc
ns_puts [string map " %modelname  $modelname " {
	dict set pageinfo menu " "
}] 
ns_puts [format {ns_puts [$bhtml htmltag h1 $title]} $modelname]

ns_puts {
set gridView [GridView new -model $model -bhtml $bhtml ]
ns_puts [$gridView getGridView]
}

ns_puts "%>"
%>
