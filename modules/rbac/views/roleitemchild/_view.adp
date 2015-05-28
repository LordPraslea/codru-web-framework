<%
ns_puts "testing ok?"
set html [$bhtml link -controller roleitemchild "[$model get parent_id] [$model get child]" view "parent_id [$model get parent] child_id [$model get child]"]
puts "html is $html"
ns_puts $html
%>


