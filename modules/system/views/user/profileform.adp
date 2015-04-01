<%
$model unset password
$model setAlias password [mc "New password"]
set f [Form new -model $model -bhtml $bhtml]
$f allErrors
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
	
set field current_password

	$f beginGroup 
	$f label $field
	$f input -type password $field
	$f errorMsg $field
	$f endGroup $field 
	
set field password

	$f beginGroup 
	$f label $field
	$f input -type password $field
	$f errorMsg $field
	$f endGroup $field 
	
set field retype_password

	$f beginGroup 
	$f label $field
	$f input -type password $field
	$f errorMsg $field
	$f endGroup $field 

	$f add [$bhtml input -type hidden update_type password]
$f submit [mc "Change password"] 
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
set form [$f endForm  -action $url -method post -id authors -class "col-sm-8"]

set formdiv [$bhtml panel -h "Change password" -type warning $form]
ns_puts [$bhtml tag -htmlOptions [list class col-sm-6] div $formdiv]
$f destroy



#################3
#Setting language and TimeZone
##################

set f [Form new -model $model -bhtml $bhtml]
$f allErrors
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
	
set field language

	$f beginGroup 
	$f label $field
	$f input -type text $field
	$f errorMsg $field
	$f endGroup $field 
	
set field timezone

	$f beginGroup 
	$f label $field
	$f input -type text $field
	$f errorMsg $field
	$f endGroup $field 
	

	$f add [$bhtml input -type hidden update_type time_lang]
$f submit [mc "Update"] 
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
set form [$f endForm  -action $url -method post -id authors -class "col-sm-8"]
$f destroy
ns_puts [$bhtml panel -h "Update language and timezone" -type success -size col-sm-6 $form]


#Form for UserProfile..
#If nothing in userprofile.. show everything he needs to fill in
#exactly as things that are already added:)
set f [Form new -model $userprofilemodel -bhtml $bhtml]
$f allErrors
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]

set attributes [$userprofilemodel getAttributes]
#puts "Attributs $attributes"
if {[dict exists $attributes extrafields]} {
	foreach {id field} [dict get $attributes extrafields] {

		$f beginGroup 
		$f label $field
		$f input $field
		$f errorMsg $field
		$f endGroup $field 
	}
} else {
 $f add "There seems to be no extra User Profile details."
}
	

	$f add [$bhtml input -type hidden update_type profile]
$f submit [mc "Update Profile Information"] 
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
set form [$f endForm  -action $url -method post -id authors -class "col-sm-8"]

$f destroy

ns_puts [$bhtml panel -h "Update Profile Information" -type success -size col-sm-6 $form]
#set formdiv [$bhtml panel -h "Update Profile Information" -type success -active 1 $form]
#ns_puts [$bhtml tag -htmlOptions [list class col-sm-6] div $formdiv]

%>


