<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias id] } {[$model get id] 
} {	[$model getAlias name] } {[$model get name] 
} {	[$model getAlias type] } {[$model get type] 
} {	[$model getAlias description] } {[$model get description] 
} {	[$model getAlias bizrule] } {[$model get bizrule] 
} {	[$model getAlias data] } {[$model get data] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias id]] [$model get id] <br>	
 [$bhtml htmltag strong [$model getAlias name]] [$model get name] <br>	
 [$bhtml htmltag strong [$model getAlias type]] [$model get type] <br>	
 [$bhtml htmltag strong [$model getAlias description]] [$model get description] <br>	
 [$bhtml htmltag strong [$model getAlias bizrule]] [$model get bizrule] <br>	
 [$bhtml htmltag strong [$model getAlias data]] [$model get data] <br>	" 
%>


