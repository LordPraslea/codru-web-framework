<%
	#This generates the view use it later to also generate _view 
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"
#Include page title
ns_puts [format {
set title [mc "Index of %%s"]

dict set pageinfo title $title} $modelname]

#Breadcrumbs include
ns_puts [string map "%modelname $modelname %controller [string tolower $modelname]"  {
		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu " "
}]

#Include MENU for buttons.. etc
ns_puts {ns_puts [$bhtml htmltag h1 $title]}
foreach col $columns {
	lappend dcols $col 
}
ns_puts [format {
	ns_puts [$bhtml detailView $model  {%s}]
} $dcols]


ns_puts "%>"
%>
