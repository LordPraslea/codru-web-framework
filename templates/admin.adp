
<%
	#This generates our beloved index page..
	
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"
#Include page title
ns_puts [format {
set title [mc "Admin page for %s"]
dict set pageinfo title $title 
} $modelname]

#TODO MODULE
#Breadcrumbs include
ns_puts [string map "%modelname $modelname %controller [string tolower $modelname] %module $module"  {
	dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} \"/\"}
			%module	
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 $title}
		" 
dict set pageinfo menu " "
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

ns_puts {set gridView [GridView new -searchBar 1 -admin 1 -model $model -bhtml $bhtml ]
ns_puts [$gridView getGridView]
}

ns_puts "%>"


%>
