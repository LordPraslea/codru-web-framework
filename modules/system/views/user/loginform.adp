
<%

$model nodjsRules $bhtml
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
if {0} {	
set field email

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
	
	}
set field longlogin

	$f beginGroup 
	$f checkbox $field 
	$f errorMsg $field
	$f endGroup $field 

	$f captcha css


$f submit [mc "Login"] xsubmit "btn-block btn-lg" 


set extraLinks {<p class="text-center"><br>} 
append extraLinks [$bhtml a -simple 1 [mc "Create a new account"] [my getUrl -controller user register]] 	 {
<br>}  [$bhtml a -simple 1 [mc "Forgotten your password?"] [my getUrl -controller user reset]] "</p>"

$f add $extraLinks
set loginform [$f endForm  -horizontal 0 -action [my getUrl -controller user login] -method post -id users ]
ns_puts [$bhtml panel -h [mc "Log in"] -type primary -size "col-xs-12 col-sm-10 col-md-6 col-lg-5" $loginform]
$f destroy
%>


