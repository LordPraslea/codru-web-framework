<%
ns_puts "<%"
set data "\n"
set newdata "\n \[\$bhtml a {\[\$model getAlias id\] \[\$model get id\]} \[my getUrl view \[list id \[\$model get id\] \] \] \]  "
foreach col $columns {
	lappend data "\t\[\$model getAlias $col\] " "\[\$model get $col\] \n"
	append newdata "\n \[\$bhtml htmltag strong \[\$model getAlias $col\]\] \[\$model get $col\] <br>\t"
}

ns_puts [format {ns_puts [$bhtml desc -horizontal 1 [subst { %s }] ]} $data]
ns_puts [format {ns_puts  "%s" } $newdata]

ns_puts "%>"
%>
