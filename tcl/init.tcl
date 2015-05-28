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
set cacheTime 180

foreach pkg {TclOO nx  nx::serializer msgcat tclgd base64 json} {
	package require $pkg
}
msgcat::mcload [ns_server pagedir]/lang
namespace import msgcat::mc

#Cache creation
ns_runonce {
	ns_cache_create -timeout 7 -expires 3600  lostmvc [expr 20*1024*1024]
}
if {0} {
#NaviServer loads this file init.tcl first
#Then it proceeds to all other files from this folder sorted
#However we need to load all other files before Controller and Model
#In the past we did this by renaming Model and Controller to xController xModel .. 
#Not an obvious choice.. now it's better this way, in the future maybe subdevide to subfolders
#Load All files except the ones specified in loadLater
set loadLater "Model.tcl Controller.tcl"
#Exclude this file and config.tcl
set excludeFiles "init.tcl config.tcl"

set lostmvcDir [file dirname [info script]]
set files [lsort  [glob -nocomplain -dir  $lostmvcDir *.tcl]]
#puts "\nAll Files $files \n"
foreach file $files {
	if {[file tail $file] in $excludeFiles} { continue }
	if {[file tail $file] ni   $loadLater} { source $file }
}
foreach file $loadLater {
	source $lostmvcDir/$file
}

}

#Register GENERATOR 
foreach method {GET POST} {
	ns_register_adp $method /lostmvcgenerator [ns_config ns/parameters tcllibrary]/lostmvc/generator.adp
} 	

#Custom pages
ns_adp_ctl detailerror on ;#off
ns_adp_ctl displayerror on ;#off
#ns_adp_ctl stricterror true
#ns_adp_ctl errorpage ../error.adp


