
<%
	#This generates our creation page 
	
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"

#Include page title
ns_puts [format {
set title "[mc Updating] [mc %s] with id [$model get id]"
dict set pageinfo title $title
} $modelname]

#Breadcrumbs include
ns_puts [string map "%modelname $modelname %controller [string tolower $modelname]"  {
		dict set pageinfo breadcrumb [subst  { 
			{-url 1 {[mc Home]} {#}}
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 "$title"}
		}]

	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc %modelname]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc %modelname]} [my getUrl create]}
	{  -url 1   {[mc Delete] [mc %modelname]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 0   {[mc Admin] [mc %modelname]} [my getUrl admin]}
"
}]

#Include MENU for buttons.. etc
#TODO include update information..
ns_puts [format {ns_puts [$bhtml htmltag h1 "$title"]} $modelname]

#Eventually pass the $model ?
ns_puts {ns_puts [ns_adp_parse -file form.adp ]}

ns_puts "%>"
%>
