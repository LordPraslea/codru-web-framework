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
			{-url 1 {[mc Home]} {/}}
			{-url 1 {[mc %modelname]} /%controller/index}
			{-active 1 "$title"}
		}]

	set id [$model get id]
dict set pageinfo menu "
"
}]

ns_puts [format {ns_puts [$bhtml htmltag h1 "$title"]} $modelname]

#Eventually pass the $model ?
ns_puts {ns_puts [ns_adp_parse -file form.adp ]}

ns_puts "%>"
%>
