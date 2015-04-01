<%
#set time [clock milliseconds]
#
#SiteController differs for sure for each website so we load it anew
#ns_adp_include -tcl -nocache  [ns_server pagedir]/controllers/SiteController.tcl   
set c [SiteController new]

$c  urlAction
#puts "Time for page [expr {([clock milliseconds]-$time)/1000.}]"

%>


