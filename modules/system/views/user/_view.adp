<%
ns_puts [$bhtml desc -horizontal 1 [subst { {	[$model getAlias id] } {[$model get id] 
} {	[$model getAlias username] } {[$model get username] 
} {	[$model getAlias password] } {[$model get password] 
} {	[$model getAlias retype_password] } {[$model get retype_password] 
} {	[$model getAlias email] } {[$model get email] 
} {	[$model getAlias last_login_at] } {[$model get last_login_at] 
} {	[$model getAlias creation_at] } {[$model get creation_at] 
} {	[$model getAlias activation_code] } {[$model get activation_code] 
} {	[$model getAlias status] } {[$model get status] 
} {	[$model getAlias password_reset_at] } {[$model get password_reset_at] 
} {	[$model getAlias password_code] } {[$model get password_code] 
} {	[$model getAlias creation_ip] } {[$model get creation_ip] 
} {	[$model getAlias login_attempts] } {[$model get login_attempts] 
} {	[$model getAlias temp_login_block_until] } {[$model get temp_login_block_until] 
} }] ]
ns_puts  "
 [$bhtml a {[$model getAlias id] [$model get id]} [my getUrl view [list id [$model get id] ] ] ]  
 [$bhtml htmltag strong [$model getAlias id]] [$model get id] <br>	
 [$bhtml htmltag strong [$model getAlias username]] [$model get username] <br>	
 [$bhtml htmltag strong [$model getAlias password]] [$model get password] <br>	
 [$bhtml htmltag strong [$model getAlias retype_password]] [$model get retype_password] <br>	
 [$bhtml htmltag strong [$model getAlias email]] [$model get email] <br>	
 [$bhtml htmltag strong [$model getAlias last_login_at]] [$model get last_login_at] <br>	
 [$bhtml htmltag strong [$model getAlias creation_at]] [$model get creation_at] <br>	
 [$bhtml htmltag strong [$model getAlias activation_code]] [$model get activation_code] <br>	
 [$bhtml htmltag strong [$model getAlias status]] [$model get status] <br>	
 [$bhtml htmltag strong [$model getAlias password_reset_at]] [$model get password_reset_at] <br>	
 [$bhtml htmltag strong [$model getAlias password_code]] [$model get password_code] <br>	
 [$bhtml htmltag strong [$model getAlias creation_ip]] [$model get creation_ip] <br>	
 [$bhtml htmltag strong [$model getAlias login_attempts]] [$model get login_attempts] <br>	
 [$bhtml htmltag strong [$model getAlias temp_login_block_until]] [$model get temp_login_block_until] <br>	" 
%>


