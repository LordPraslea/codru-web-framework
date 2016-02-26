
<%

set f [Form new -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors

	
set field name

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field type

	$f beginGroup 
	$f label $field
	$f select $field [$model getProfileType]
	$f errorMsg $field
	$f endGroup $field 
	
set field required

	$f beginGroup 
	$f add 	[$bhtml toggle -size normal -ontype danger -offtype success [mc "Required"] [mc "Optional"] [$model classKey $field]] 
	$f errorMsg $field
	$f endGroup $field 
	

$f submit [mc "Submit"] 
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id authors -class "col-sm-7"]
$f destroy

%>


