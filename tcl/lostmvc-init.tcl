#This loads everything for LostMVC
# you need to include this file only when testing and modifying things
#	 LostMVC version 1.0	 -	 http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014 United Brain Power <info@unitedbrainpower.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# Cache how long?
#puts "\n=-=-=-=-=-=-=-=-=-\n Loading the LostMVC INIT file!  \n=-=-=-=-=-=-=-=-=-\n "
set cacheTime 180

set framework_dir "lostmvc"
#TODO Fix loading of server models/controllers only when needed
foreach pkg {TclOO nx sha256 msgcat tclgd base64 json} {
	package require $pkg
}
msgcat::mcload [ns_server pagedir]/lang
namespace import msgcat::mc


#Cache creation
ns_runonce {
	ns_cache_create -timeout 7 -expires 3600  lostmvc [expr 20*1024*1024]
}
#Load Config


#Source all other things
set libraries {config.tcl Functions.tcl  Model.tcl Bhtml.tcl Plugins.tcl Form.tcl Controller.tcl Loader.tcl config.tcl } ;# {../archives/ruff/ruff.tcl} 
foreach lib $libraries {
#ns_adp_include -tcl -cache $cacheTime  database.tcl 
#
#	ns_adp_include -tcl -cache $cacheTime   $lib 
#	ns_adp_include -tcl  $lib 
}
#Custom pages
ns_adp_ctl detailerror on ;#off
ns_adp_ctl displayerror on ;#off
#ns_adp_ctl stricterror true
#ns_adp_ctl errorpage ../error.adp

#ns_register_adp GET /user/* /var/www/localhost/lostmvc/user.adp
#ns_register_adp GET /user/* [ns_server pagedir]/lostmvc/user.adp

#ns_adp_include -tcl  -cache 0001  nssession.tcl 


#puts "Finished loading all files! "

