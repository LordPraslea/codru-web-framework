

<%
set title [mc "Reset forgotten password"]
dict set pageinfo title $title 

dict set pageinfo  breadcrumb [subst  {
			{-url 1 [mc Home] "/"}
			{-active 1 $title}
		} ]  

ns_puts [$bhtml htmltag h1 $title]
#ns_puts [ns_adp_parse -file form.adp ]
set f [Form new -formType normal -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors
$model setAlias email [$model getAlias user_or_email]
set field email

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 

$f captcha

	$f input -type hidden code 
$f submit [mc "Reset my password"] xsubmit "btn-block btn-lg" 


ns_puts [$f endForm  -horizontal 0 -action [my getUrl reset] -method post -id authors -class "col-sm-4"]
$f destroy
%>


