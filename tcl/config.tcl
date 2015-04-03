#Config settings 
appname		unitedbrainpower
lang	ro
routes {
	/blog/*   ./modules/cms/controllers/PostController.adp
	/cms/*   ./modules/cms/controllers/PostController.adp
}
loadFrom lostmvc	
forceMultilingual 0
database dbipg2
names {website UnitedBrainPower.com sitename "United Brain Power" }
email info@unitedbrainpower.com
mode dev
mailsettings { username yourgmailaddress@gmail.com password WW91clBhc3N3b3JkSGVyZQ== }

