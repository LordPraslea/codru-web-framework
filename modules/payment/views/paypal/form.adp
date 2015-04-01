
<%

set f [Form new -formType normalex $model $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with <span class=\"required\">*</span> are requried."]]
$f allErrors
	
set field subscription

	$f beginGroup 
	$f label $field 
	$f select $field [my subscription]
	$f errorMsg $field
	$f endGroup $field 
	
$f submit  [mc "Buy Subscription through Paypal"]
set url [ns_conn url]
set url "/paypal/createPayment"
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id authors -class "col-sm-12"]
$f destroy

%>


