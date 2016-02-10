
<%

set f [Form new -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors
set field id

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field username

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field password

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field retype_password

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field email

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field last_login_at

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field creation_at

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field activation_code

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field status

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
	set field user_type

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
	
set field password_reset_at

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field password_code

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field creation_ip

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field login_attempts

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
set field temp_login_block_until

	$f beginGroup 
	$f label $field
	$f input $field
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


