<%
#set time [clock milliseconds]
#ns_adp_include -tcl -nocache  [ns_server pagedir]/tcl/init.tcl   
set c [PostController new]
$c urlAction
#puts "Time for page [expr {([clock milliseconds]-$time)/1000.}]"

%>


