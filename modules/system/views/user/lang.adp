<%
	#Language settings
	#
	#
set title [mc "Change your language:"]
dict set pageinfo title  $title 
set bhtml [bhtml new]
#encoding system  utf-8
#ns_conn encoding UTF-8
#encoding system iso8859-2
if {0} {
ns_conn encoding  ISO-8859-2
ns_conn encoding ISO-10646
}
#ns_puts "[ns_conn encoding] [encoding system]"
	if {[info exists infoalert]} {
		ns_adp_puts  [$bhtml alert {*}$infoalert]
	}
	ns_adp_append [$bhtml tag   h2 $title]
	set lang  [encoding convertfrom utf-8 "English en Română ro  Nederlands nl"]
#	set lang  "English en Română ro  Nederlands nl"
	foreach {language ln} $lang  {
		ns_adp_puts [$bhtml link -controller user -lang $ln $language   lang [list lang $ln]]<br>
	}
	
	if {0} {
	set f [Form new -formType normal $model $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with * are requried."]]
$f allErrors

	
set field language

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 


$f submit [mc "Login"] xsubmit "btn-block btn-lg" 

ns_puts [$f endForm  -horizontal 0 -action /user/login -method post -id authors -class "col-sm-4"]
$f destroy
	}
%>
