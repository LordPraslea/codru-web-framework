<%


append page [$bhtml messenger -location top -theme flat "Hello World!"]
append page [$bhtml messenger -type error "Do you really want to delete everything?"]
append page [$bhtml messenger -type success -location bottom -theme air "Feeling good today?"]
ns_puts $page
%>
