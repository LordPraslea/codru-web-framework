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
			{-url 1 {[mc Home]} #}
			{-active 1 {[mc %s]} }
		"} $modelname] 
#Include MENU for buttons.. etc
ns_puts [string map " %modelname  $modelname " {
dict set pageinfo menu "
	{  -url 1   {[mc Create] [mc %modelname]} [my getUrl create]}
	{  -url 1 -show 0   {[mc Admin] [mc %modelname]} [my getUrl admin]}
"
}] 
ns_puts [format {ns_puts [$bhtml htmltag h1 $title]} $modelname]

ns_puts {ns_puts [$bhtml gridView $model ]}
if {0} {
set data "\n"
foreach col $columns {
	append data "\t\[\$model getAlias \$col\] " "\[\$model get \$col\] \n"
}
ns_puts "#This generates a dd dl definition.."
ns_puts [format {[$bhtml desc -horizontal 1 { %s }]} $data]
}
ns_puts "%>"
%>
