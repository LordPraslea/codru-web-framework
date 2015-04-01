<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias item_id] } {[$model get item_id] 
} {	[$model getAlias user_id] } {[$model get user_id] 
} {	[$model getAlias bizrule] } {[$model get bizrule] 
} {	[$model getAlias data] } {[$model get data] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias item_id]] [$model get item_id] <br>	
 [$bhtml htmltag strong [$model getAlias user_id]] [$model get user_id] <br>	
 [$bhtml htmltag strong [$model getAlias bizrule]] [$model get bizrule] <br>	
 [$bhtml htmltag strong [$model getAlias data]] [$model get data] <br>	" 
%>


