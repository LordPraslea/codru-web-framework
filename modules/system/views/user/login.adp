
<%
set title [mc "Log in"]
dict set pageinfo title $title 
dict set pageinfo  breadcrumb "
			{-url 1 [mc Home] /index }
			{-active 1 $title }
		"
ns_puts [$bhtml htmltag h1 $title]
if {[info exists extrainfo]} {
	ns_puts $extrainfo
}
if {[ns_session contains sessionexpired]} {
	set expired [ns_session get sessionexpired]
	if {$expired} {
		ns_puts [$bhtml alert "You need to log in to view the page you're trying to access. (Your session has expired)."]
		ns_session put sessionexpired 0
	}
}
ns_puts [ns_adp_parse  -file loginform.adp ]
#ns_puts {<div class="col-sm-7">}
#ns_puts [$bhtml a [mc "Create a new account"] /user/register]\ |\ [$bhtml a [mc "Forgotten your password?"] /user/reset]
%>


