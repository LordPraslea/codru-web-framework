<%
set config {
#Config settings 
appname		%domainname
lang	ro
routes {
	/blog/*   ./modules/cms/controllers/PostController.adp
	/cms/*   ./modules/cms/controllers/PostController.adp
}
forceMultilingual 1
database %database
names {website %domainname sitename "Your Site Name Here" }
email info@%domainname
mode dev
mandrill {  host smtp.mandrillapp.com port 587 username yourgmailaddress@gmail.com password your-mandrill-api }
}
%>
