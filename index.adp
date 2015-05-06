<% 
ns_adp_include -tcl -nocache  ./tcl/init.tcl   
set title  "Lost MVC"
set keywords "LostMVC"
set bhtml [bhtml new]
$bhtml addPlugin mycover { 
			css "/css/ubp.css"
			css-min "/css/ubp.css"
		}

append page "<h1>LostMVC</h1>"
append page {
	Welcome to LostMVC!
}
ns_adp_include -cache 100 ./views/layout.adp -bhtml $bhtml -title $title -keywords  $keywords  $page  
%>

