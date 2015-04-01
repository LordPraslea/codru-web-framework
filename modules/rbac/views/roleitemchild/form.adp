
<%

set f [Form new  -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors
set field parent_id
 set data [$model search -table role_item [list name id ]  ] 
 #ns_puts "data is $data"
	$f beginGroup 
	$f label $field
	$f select $field [dict get $data values]
	$f errorMsg $field
	$f endGroup $field 
	
set field child_id

 #set data [$model search -table role_item [list name id ]  ] 
	$f beginGroup 
	$f label $field
	$f select $field [dict get $data values] 
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


