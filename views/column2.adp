<%

ns_parseargs { {-title ""} {-keywords ""} {-author ""} {-description ""} {-pageinfo ""} {-bhtml nobhtml} {-controller "" } -- page  } [ns_adp_argv]

set newpage {
	<style>
div.col-xs-9 h1 {
    margin-top: 0;
}
	</style>
 <div class="col-lg-3 pull-right">
}

if {[dict exists $pageinfo menu]} {
append newpage  [$bhtml nav -tabs 0 -class "pull-righty nav-stacked" -style "max-width: 200px;;" [dict get $pageinfo menu]]
}
if {[dict exists $pageinfo sidebar]} {
#append newpage  [$bhtml nav -tabs 0 -class "pull-righty nav-stacked" -style "max-width: 200px;;" [dict get $pageinfo menu]]
append newpage  [dict get $pageinfo sidebar]
}
append newpage {</div> <div class="col-lg-9">}
append newpage $page

append newpage {</div>}

set currentFile [file dir [lindex [ns_adp_info] 0]]
set newFile [file join $currentFile ../views/layout.adp] 
if {[ns_filestat $newFile ]} { 
	ns_adp_include  $newFile -pageinfo $pageinfo -bhtml $bhtml -controller $controller  $newpage
} else {
	ns_adp_include  [ns_server pagedir]/lostmvc/views/layout.adp   -pageinfo $pageinfo -bhtml $bhtml -controller $controller  $newpage
}
#ns_adp_include ../views/layout.adp -pageinfo $pageinfo -bhtml $bhtml  $newpage
%>
