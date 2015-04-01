<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias parent_id] } {[$model get parent_id] 
} {	[$model getAlias child_id] } {[$model get child_id] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias parent_id]] [$model get parent_id] <br>	
 [$bhtml htmltag strong [$model getAlias child_id]] [$model get child_id] <br>	" 
%>


