
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

set field email

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

set field agree

	$f beginGroup 
	$f checkbox $field 
	$f errorMsg $field
	$f endGroup $field 

	$f captcha
	
#$f add [$bhtml htmltag p [mc "By registering you agree to the terms and conditions."]]
$f submit [mc "Register"] xsubmit "btn-block btn-lg"
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
set registerform [$f endForm  -action [my getUrl -controller user register]  -method post -id authors ]
set panel [$bhtml panel -h  [mc  "Register - Create a new user" ] -type success -size "col-sm-5 col-md-5 col-lg-5 " $registerform]
ns_puts [$bhtml tag -htmlOptions [list class text-block] div $panel]
$f destroy

%>


