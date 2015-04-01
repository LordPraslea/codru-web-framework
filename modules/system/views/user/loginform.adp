
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

	$f captcha


$f submit [mc "Login"] xsubmit "btn-block btn-lg" 

$f add <p\ class="text-center"><br>[$bhtml a [mc "Create a new account"] [my getUrl register]]\ <br>\ [$bhtml a [mc "Forgotten your password?"] [my getUrl reset]]</p>

ns_puts [$f endForm  -horizontal 0 -action [my getUrl login] -method post -id users -class "col-sm-4"]
$f destroy
%>


