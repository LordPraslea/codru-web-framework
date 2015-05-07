<%
#Specify what this layout needs
ns_parseargs { {-title ""} {-keywords ""} {-author ""} {-breadcrumb ""} {-description ""} {-pageinfo ""} {-bhtml nobhtml} {-header ""} {-nocontent 0} {-controller ""} -- page  } [ns_adp_argv]
#ns_adp_bind_args page title keywords
#ns_puts "$name and page $page and $title and $keywords"
#Overwrite normal settings from pageinfo dict
set allowed [list title keywords description author breadcrumb menu controller nocontent header]
foreach {key val} $pageinfo {
	#if not in list.. just overwrite
	if {[lsearch $allowed $key] == -1} {  continue }
	set $key $val
}
%>
<!DOCTYPE html>
<html lang="<%= [ns_session get urlLang] %>">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="description" content="<%= $description  %>">
		<meta name="author" content="<%= $author  %>">
		<meta name="keywords" content="<%= $keywords  %>">
		<link rel="shortcut icon" href="/img/favicon.ico">


		<title><%= $title %></title>
	<% $bhtml addPlugin fontawesome { 
				css  "/css/font-awesome.css"
				css-min  "/css/font-awesome.min.css"
			}
			%>
		<%= [$bhtml includeCssPlugins] %>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
<noscript><style>
	.jsonly { display: none }
	.dropdown:hover .dropdown-menu {
		display: block;
	}
	.dropup:hover .dropdown-menu {
		display: block;
	}
		
</style></noscript>
</head>

<body>

    <!-- Navigation -->
	<%
 set brand {<img style="margin-top: -0.5em; padding-left:2em; height:200%" title="Lost MVC" src="/img/logo.png"/>}
	 	if {[ns_session contains userid]} {
			set data [subst   {
			{ -url 1 -fa fa-cogs {[mc "Profile"]} {[$controller getUrl -controller user profile]}} 
			{ -url 1 -fa fa-sign-out {[mc "Log Out"]} {[$controller getUrl -controller user logout]}}
			}]
				set auth [list -dropdown  1   -nav 1 "[$bhtml fa fa-user] [ns_session get username]" $data  ]
				#set auth [list -url 1 [concat [mc "Log Out"] " ([ns_session get username])"] "/user/logout"]
			} else {
				set auth [list -url 1 [concat [$bhtml fa fa-sign-in] [mc "Log In"]] [$controller getUrl -controller user login]]
			}
set data [list 	[list -url 1 -fa fa-book  Blog [$controller getUrl -controller false blog/index]] ]

lappend data [list -dropdown true -nav 1 -type success  "[$bhtml fa fa-briefcase]	 [mc Projects]" {
		{-url 1 "Your Daily project" /YourdailyProject/ }
		{-url 1 "Love the Way You do This" /yeah/ }
	} ]
	lappend data			[list -url 1 "Join us!" [$controller getUrl -controller user register]]		[list -url 1 Contact [$controller getUrl  contact  ]]
		#	puts "auth is $auth"
			#lappend data $auth
#	puts "\n\n\$data is $data \n\n \$auth is $auth"
	%>
  	<%=  [$bhtml navbar -class "navbar-fixed-top navbar-default" -brand "$brand " -brandUrl /  -navbarclass "navbar-left"  -navbarclass2 navbar-right $data [list $auth] ] %>


<%= $header %>



    <!-- Page Content -->

    </div>

<a name="maincontent"></a>
<% #if {[info exists breadcrumb]}  { [$bhtml breadcrumb  $breadcrumb] } %>

<%
if {!$nocontent} {
	ns_puts { <div style="margin-top:60px;"> </div> }
	if {$breadcrumb != ""} { ns_puts [$bhtml breadcrumb -container true $breadcrumb] } 
	ns_puts {

		<div class="content-section-a">

			<div class="container">
	}
}
		%>
<%
#set page [encoding convertfrom utf-8 $page]
ns_puts $page ;# [ns_adp_argv 0] ;# $page
#puts "Page is $page"

%>

<%
if {!$nocontent} {
ns_puts {
        </div>
        <!-- /.container -->
}
}
%>


    <!-- Footer -->
    <footer>
        <div  class="container">
            <div class="row" style="text-align:center">
                <div class="col-lg-12">
				<%= [$bhtml nav -tabs 0 -class "col-xs-offset-4" $data] %> 
				<%= [$bhtml a -fa fa-file-text "Terms of Use" ] %> -
				<%= [$bhtml a -fa fa-lock "Privacy Policy" ] %> -
				<% ns_adp_puts  [$controller generateLanguageLinks $bhtml] %> 
                    <p class="copyright text-muted small">Copyright &copy; United Brain Power 2014-2015. All Rights Reserved</p>
                </div>
            </div>
        </div>
    </footer>


   

<%= [$bhtml components] %>
<%= [$bhtml includeJsPlugins] %>
<%= [$bhtml putScripts] %>
</body>

</html>
