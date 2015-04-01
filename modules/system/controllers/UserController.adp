<%
#ns_adp_include -tcl -nocache  [ns_server pagedir]/tcl/init.tcl   
set c [UserController new]
#TODO do [pre|post]Action here if not in urlAction or not in preauth filter! 
# $c preAction
$c urlAction
# $c postAction
ns_puts "[ns_server pagedir] [ns_pagepath]"
%>


