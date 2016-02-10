
<%

set f [Form new -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors

set field username

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field password

	$f beginGroup 
	$f label $field
	$f input -type password $field
	$f errorMsg $field
	$f endGroup $field 
	
set field email

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field credits

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	


$f submit [mc "Create new account"] 
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id user -class "col-sm-7"]
$f destroy

%>


