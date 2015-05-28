<%
set config {
#Config settings 
appname		unitedbrainpower
lang	ro
routes {
	/blog/*   ./modules/cms/controllers/PostController.adp
	/cms/*   ./modules/cms/controllers/PostController.adp
}
loadFrom lostmvc	
forceMultilingual 1
database dbipg2
names {website UnitedBrainPower.com sitename "United Brain Power" }
email info@unitedbrainpower.com
mode dev
mandrill {  host smtp.mandrillapp.com port 587 username yourgmailaddress@gmail.com password your-mandrill-api }
}
%>
