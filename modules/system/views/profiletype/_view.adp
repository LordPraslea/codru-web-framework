<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias id] } {[$model get id] 
} {	[$model getAlias name] } {[$model get name] 
} {	[$model getAlias type] } {[$model get type] 
} {	[$model getAlias required] } {[$model get required] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias id]] [$model get id] <br>	
 [$bhtml htmltag strong [$model getAlias name]] [$model get name] <br>	
 [$bhtml htmltag strong [$model getAlias type]] [$model get type] <br>	
 [$bhtml htmltag strong [$model getAlias required]] [$model get required] <br>	" 
%>


