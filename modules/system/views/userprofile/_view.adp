<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias user_id] } {[$model get user_id] 
} {	[$model getAlias profile_id] } {[$model get profile_id] 
} {	[$model getAlias profile_value] } {[$model get profile_value] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias user_id]] [$model get user_id] <br>	
 [$bhtml htmltag strong [$model getAlias profile_id]] [$model get profile_id] <br>	
 [$bhtml htmltag strong [$model getAlias profile_value]] [$model get profile_value] <br>	" 
%>


