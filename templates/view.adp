
<%
	#This generates the view use it later to also generate _view 
	  
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"
#Include page title
ns_puts [format {
set title [mc "Index of %%s" [mc %s]]

dict set pageinfo title $title} $modelname]

#Breadcrumbs include
ns_puts [string map "%modelname $modelname %controller [string tolower $modelname]"  {
		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc %modelname]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc %modelname]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc %modelname]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc %modelname]} [my getUrl delete [list id $id]]}
	{  -url 1 -show 1   {[mc Admin] [mc %modelname]} [my getUrl admin]}
"
}]

#Include MENU for buttons.. etc
ns_puts {ns_puts [$bhtml htmltag h1 $title]}
foreach col $columns {
	lappend dcols $col 
}
ns_puts [format {
	ns_puts [$bhtml detailView $model  {%s}]
} $dcols]

if {0} {
set data "\n"
foreach col $columns {
	lappend data "\t\[\$model getAlias $col\] " "\[\$model get $col\] \n"
	lappend tablehead "\t\[\$model getAlias $col\] \t " 
	lappend tabledata "\t\[\$model get $col\]  \t" 
}


ns_puts [format {ns_puts [$bhtml desc -horizontal 1 [subst { %s }] ]} $data]
ns_puts [ format  {
set tablehead "%s";
set tabledata "%s";
ns_puts  [$bhtml table -bordered 1 -striped 1 -hover 1 -rpr 0  $tablehead $tabledata]
ns_puts  [$bhtml tableHorizontal -bordered 1 -striped 1 -hover 1 -rpr 0  $tablehead $tabledata]
} $tablehead   $tabledata ]
}
ns_puts "%>"
%>
