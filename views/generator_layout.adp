<%
#Specify what this layout needs
ns_parseargs { {-title ""} {-keywords ""} {-author ""} {-description ""} {-bhtml nobhtml} -- page  } [ns_adp_argv]
#TODO Figure out another way to do this.. maybe with ns_parseargs ..?:D
#ns_adp_bind_args page title keywords
#ns_puts "$name and page $page and $title and $keywords"
%>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="<%= $description  %>">
		<meta name="author" content="<%= $author  %>">
		<meta name="keywords" content="<%= $keywords  %>">
		<link rel="shortcut icon" href="./favicon.ico">

		<title><%= $title %></title>

		<%= [$bhtml includeCssPlugins] %>

		<!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
		<!--[if lt IE 9]>
		<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
		<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
		<![endif]-->
	</head>
	<% # ns_adp_include -tcl  -nocache tcl/init.tcl    %>
	<body>
    <div class="container">
      <div class="header">
		  
		  	<%=  [$bhtml nav -active [ns_queryget a] -tabs 0 -class "pull-right" {
			{ -url 1  "Home" ""} 
			{ -url 1 "Model generator" "?a=model"}
			{ -url 1  "Controller generator" "?a=controller"}
			{ -url 1  "CRUD generator" "?a=crud"}
			{ -url 1  "RBAC generator" "?a=rbac"}
			}] %>

        <h3 class="text-muted">Lost MVC </h3>
        <br>
          	<%=  [$bhtml navbar -class "navbar-static-top" -brand "LostMVC Generators"  -active [ns_queryget a] {
			{-url 1  "Model " ?a=model }
			{-url 1 "Controller" ?a=controller }
			{-url 1  "CRUD" ?a=crud }
			{-url 1  "RBAC" ?a=rbac }
			}] %>
      </div>

<%
ns_puts $page ;# [ns_adp_argv 0] ;# $page

%>
</div>
<%= [$bhtml components] %>
<%= [$bhtml includeJsPlugins] %>
<%= [$bhtml putScripts] %>
	</body>
</html>


