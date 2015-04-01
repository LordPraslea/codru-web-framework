<%
set title [mc "Change password"]
dict set pageinfo title $title 

dict set pageinfo breadcrumb [subst  {
			{-url 1 [mc Home] "#"}
			{-active 1 $title}
		} ]  

ns_puts [$bhtml htmltag h1 $title]
#ns_puts [ns_adp_parse -file form.adp ]
set f [Form new -formType normal $model $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p ""]
$f allErrors
#TODO field for OLD password..
set field password

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
	
#TODO CAPTCHA!!

$f submit [mc "Change password"] xsubmit "btn-block btn-lg" 


ns_puts [$f endForm  -horizontal 0 -action  [my getUrl changePassword] -method post -id authors -class "col-sm-4"]
$f destroy
%>


