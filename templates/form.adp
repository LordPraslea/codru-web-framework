<%
	#This generates the form 
	  
#ns_parseargs { unused  columns } [ns_adp_argv] ;#When using ns_adp_parse
%>
<%
ns_puts "<%"

ns_puts {
set f [Form new -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with <span class=\"required\">*</span> are requried."]]
$f allErrors}

foreach field $columns {
	ns_puts "set field $field"
	ns_puts {
	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	}
}

ns_puts {
$f submit [expr {[$model isNewRecord]? [mc "Add"]: [mc "Update"]}]
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id authors -class "col-sm-7"]
$f destroy
}
ns_puts "%>"
%>
