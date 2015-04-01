
<%
	#This generates our beloved index page..
	
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"
#Include page title
ns_puts [format {
set title [mc "Admin page for %%s" [mc %s]]
dict set pageinfo title $title 
} $modelname]

#TODO MODULE
#Breadcrumbs include
ns_puts [string map "%modelname $modelname %controller [string tolower $modelname] %module $module"  {
	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"#\"}
			%module	
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 $title}
		" 
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc %modelname]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc %modelname]} [my getUrl create]}
"
} ]
#Include MENU for buttons.. etc
#
ns_puts [format {ns_puts [$bhtml htmltag h1 $title]} $modelname]
#extra data
ns_puts {
	if {[info exists infoalert]} {
		ns_puts [$bhtml alert {*}$infoalert]
	}
}

ns_puts {ns_puts [$bhtml gridView -search 1 -admin 1 $model ]}

ns_puts "%>"


if {0} {
#TODO implement columns for each page.. menu.. etc
set menu [$bhtml makeList -htmlOptions [list class "col-sm-2 pull-right"] {
	{-url 1 [mc Create] "create"}
	{-url 1 [mc Update] "update"}
	{-url 1 [mc View] "update"}
	{-url 1 [mc Delete] "delete"}
	{-url 1 [mc Admin] "delete"}
}]

set gridview [$bhtml gridView -class "col-sm-10" -search 1 -admin 1 $model ]
ns_puts [$bhtml htmltag div " $gridview $menu"]
}
%>
