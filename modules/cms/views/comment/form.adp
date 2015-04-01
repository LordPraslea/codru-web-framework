
<%
if {[info exists commentmodel]} {
set model $commentmodel
}
set f [Form new -model $model -bhtml $bhtml]
$f allErrors

set field comment

	$f beginGroup 
	$f label -fa [join  fa-comment alert-success] $field
	$f input -type textarea $field
	$f errorMsg $field
	$f endGroup $field 
	

	
 $f add [$bhtml input -type hidden iscomment  yes]
$f submit [expr {[$model isNewRecord]? [mc "Add Comment"]: [mc "Update"]}]
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id authors -class "col-sm-7 well"]
$f destroy

%>


