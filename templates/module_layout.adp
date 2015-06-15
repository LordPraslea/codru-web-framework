<%
ns_puts {
<%

ns_parseargs { {-title ""} {-keywords ""} {-author ""} {-description ""} {-pageinfo ""} {-bhtml nobhtml} {-controller "" } -- page  } [ns_adp_argv]

set newpage {
	<style>
	div.col-xs-9 h1 {
		margin-top: 0;
	}
	</style>
	<div class="col-lg-3 pull-left col-xs-6">
}

}
ns_puts [string map "%modelname $modelname %controller $controllername  %module $module"  {
if {[dict exists $pageinfo menu]} {


#TODO fix this

		dict set pageinfo menu "
	{  -url 1 -active [$controller isActiveLink /index] {[mc {List %controller}]} [$controller getUrl index]}
	{  -url 1 -active [$controller isActiveLink /create]  -show [$controller hasRole admin%controller] {[mc {Create %controller}]} [$controller  getUrl create]}
	{  -url 1 -active [$controller isActiveLink /admin]  -show [$controller hasRole admin%controller] 
		[mc {Admin %controllername}] [$controller getUrl admin]}


			[dict get $pageinfo menu]
		"
	



	append newpage  [$bhtml nav -tabs 0 -class "pull-righty nav-stacked" -style "max-width: 200px;;" [dict get $pageinfo menu]]

}
}]
ns_puts {
if {[dict exists $pageinfo sidebar]} {
#append newpage  [$bhtml nav -tabs 0 -class "pull-righty nav-stacked" -style "max-width: 200px;;" [dict get $pageinfo menu]]
append newpage  [dict get $pageinfo sidebar]

}

append newpage {</div> <div class="col-lg-9 col-xs-12">}
append newpage $page

append newpage {</div>}

set currentFile [file dir [lindex [ns_adp_info] 0]]
set newFile [file join $currentFile ../views/layout.adp] 
if {[ns_filestat $newFile ]} { 
	ns_adp_include  $newFile -pageinfo $pageinfo -bhtml $bhtml \
		-title $title -keywords $keywords -author $author -description $description  -controller $controller $newpage
} else {
	ns_adp_include  [ns_server pagedir]/views/layout.adp -pageinfo $pageinfo -bhtml $bhtml \
		-title $title -keywords $keywords -author $author -description $description -controller $controller $newpage

}
#ns_adp_include ../views/layout.adp -pageinfo $pageinfo -bhtml $bhtml  $newpage
#
%>
}
%>
