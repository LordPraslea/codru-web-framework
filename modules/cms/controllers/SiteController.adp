<%
#set time [clock milliseconds]
#
#SiteController differs for sure for each website so we load it anew
set c [SiteController new]

$c  urlAction
#puts "Time for page [expr {([clock milliseconds]-$time)/1000.}]"

%>


