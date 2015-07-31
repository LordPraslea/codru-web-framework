# 	Loader file with functions for reloading 
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
#puts "Server pagepath  [ns_pagepath] and [ns_adp_dir] pagedir [ns_server pagedir] serverdir [ns_server serverdir]"
proc defineLanguages {server} {
	set langPath  $server/lang/??.msg
	set languages ""
	foreach file [glob -nocomplain -- $langPath] {
		set lang [lindex [split [file tail $file] .] 0]
		lappend languages  $lang
	}
	return $languages

}
proc includeFromPath {path} {
#	puts "Include from path $path"
	foreach file [glob -nocomplain -- $path] {
		puts "Including with NOCACHE $file"
		ns_adp_include -tcl -nocache $file
#		puts "\tIncluded model $file"
	}
}
proc includeControllerFromPath {path {folder "" } {server ""}} {
	#puts "Controller including $folder and path $path"
	set languages [defineLanguages $server]
	set tail [file tail $folder]
	foreach file [glob -nocomplain -- $path] {
		#TODO include .tcl file at RUNTIME from the .adp file..
		#so we have the newest changes
	#	ns_adp_include $file
		set ct [lindex [split [file tail $file] .] 0]
		set cn [string tolower [string range $ct 0 [string first Controller $ct]-1]] ;#same as [$ct currentController] but without creating a object

	#	ns_cache_eval -timeout 5 -expires 600 lostmvc Loader.Controller.Routes.$ct { }
	
		#	puts "Include  controller /$cn/ path $path (/modules)/$tail/controllers/$ct.adp  for server $server"
			foreach method {GET POST DELETE} { 	
				if {$tail != ""} {
					set module [string tolower $tail]
					foreach lang $languages {
						ns_register_adp   $method /$lang/$cn/* modules/$tail/controllers/$ct.adp
					#	ns_register_filter postauth $method  /$lang/$cn/*  developmentOrProduction
					}
					ns_register_adp   $method /$cn/* modules/$tail/controllers/$ct.adp
					#ns_register_filter postauth $method  /$cn/*  developmentOrProduction
				} else  {
					foreach lang $languages {
						ns_register_adp   $method /$lang/$cn/* controllers/$ct.adp
					}
					ns_register_adp   $method /$cn/* controllers/$ct.adp
				}
			}
		#	puts "Loading Controller Routes every 10 minutes for $ct tail $tail!"

	}

if {0} {
	set langPath [ns_pagepath]/lang/??.msg
	foreach file [glob -nocomplain -- $langPath] {
		set lang [lindex [split [file tail $file] .] 0]
		lappend languages  $lang
		ns_register_adp GET /$lang/* modules/system/controllers/Controller.adp
	}
}

#	foreach method {GET POST} { 	
#		foreach lang $languages {
#			ns_register_adp $method /$lang/* modules/system/controllers/Controller.adp
#		}
#	}

	ns_register_adp GET /lang/* modules/system/controllers/Controller.adp

}
proc registerRoute {server route  location } {
	set languages [defineLanguages $server]
	foreach method {GET POST DELETE} {
		ns_register_adp   $method $route $location	
		foreach lang $languages {
			ns_register_adp $method /$lang$route $location
	#		puts "ns_register_adp $method /$lang$route $location "
		}
		#puts "ns_register_adp   $method $route $location	"
	}
}
proc allConfigRoutes {} {
#[nsv_get config routes]
#
	foreach server [glob -type d [ns_server serverdir]/* ] {
		set server_name $server/www
		set file $server/www/tcl/config.adp
		if {![file exists $file]} { continue }
		if {[info exists config]} { unset config }

		ns_adp_parse	-file  $file
	#set f [open $file r]
		#set config [read $f]
		#close $f
		if {[dict exists $config routes]} {

			puts "Exists Config: \n $config"
			foreach {route location} [dict get $config routes]  {
				registerRoute $server_name $route $location
			}
		}
	}
}; allConfigRoutes



proc lostmvcfastPath {} {
	ns_register_fastpath GET *.js
	ns_register_fastpath POST *.js
	ns_register_fastpath GET *.css
	ns_register_fastpath  POST *.css
}; lostmvcfastPath

proc getAllModels {{json 0}} {
	#Generating a list of all modules/models..
	#global modulepath
	set modulepath "[ns_pagepath]/modules/*"
	#
	set modelpath  "[ns_pagepath]/models/*.tcl"
	foreach file [glob -nocomplain -- $modelpath] {
		set model [lindex [split  [file tail $file]  .] 0]
		if {$json} {
				lappend models '$model'

		} else { 
		lappend models $model
		}

		#	puts "Getting model $file : $model"
	}
	foreach folder [glob -nocomplain -type d -- $modulepath ]  {
		set modelpath $folder/models/*.tcl
		foreach file [glob -nocomplain -- $modelpath] {
			set f [file split $file]
			set model [lindex [split  [file tail $file] .] 0]
			set module [lindex $f [lsearch $f modules]+1]
			if {$json} {
			lappend models '$module/$model'
			} else { 
			
			lappend models $module/$model
			}
		}
	}
#	puts "All models [llength $models]"
	if {[info exists models]} {
		return $models
	}
}

#Unknown handling
ns_runonce {
	
	rename unknown original_unknown
	puts "Renaming unknown to original_unknown"
}
#This procedure is supposed to load unloaded (or expired in cache) controllers,models  
# ex: UserController new  or User new 
proc unknown {args} {
	set loaded 0
	set cmdName [lindex $args 0]
	if {[lindex $args 1] eq "new"} {
		set loaded [loadControllerOrModel $cmdName]
		if {$loaded} {
		#	puts "Loading $cmdName new"
			return [$cmdName new]
		} else {
			error "\[$cmdName new\] No such file?"
		}
	}	else {
		tailcall  original_unknown {*}$args

	}
}
proc loadControllerOrModel {name} {
	set server [ns_pagepath]	

	if {0} {
	set modelpath  "$server/models/*.tcl"
	set controllerpath "$server/controllers/*.tcl"
	set modulepath "$server/modules/*"
	foreach folder [glob -nocomplain -type d -- $modulepath]  {
		lappend modelpath $folder/models/*.tcl
		lappend controllerpath $folder/controllers/*.tcl
			
	}

	puts "Modelpath $modelpath $controllerpath $controllerpath"

	foreach file [glob -nocomplain -- {*}$modelpath {*}$controllerpath] {
		set modelName [lindex [split [file tail $file] .] 0]
		puts "Current $modelName file $file"
		if {$modelName eq $name} {
			ns_adp_include $file
			return 1
		}
	}
	}
	package require fileutil
	foreach folder {controllers models modules} {
		set file [fileutil::findByPattern $server/$folder $name.tcl]
		if {$file ne "" } {
			ns_adp_include -tcl -cache 100   $file
			source   $file
			return 1
		}
	}
	return 0

}

#If in development mode, always reload controllers,models
#TODO maybe later do a reload of functions!
#

proc developmentOrProduction {args} {
	set config [ns_cache_get lostmvc config.[getConfigName]]
	if {[dict exists $config   mode]} {
		set mode [dict get $config mode]
		if {[string match dev* $mode]} {
			developmentFilesLoading
		}
	}
	puts "Filter $args"
	return filter_ok
}

proc developmentFilesLoading {} {
	set server [ns_pagepath]

	set modelpath  "$server/models/*.tcl"
	includeFromPath $modelpath

	set controllerpath "$server/controllers/*.adp"
	includeControllerFromPath $controllerpath "" $server
	set modulepath "$server/modules/*"
	foreach folder [glob -nocomplain -type d -- $modulepath]  {
		set modelpath $folder/models/*.tcl
		set controllerpath $folder/controllers/*.tcl
		includeFromPath $modelpath
		includeFromPath $controllerpath
	}
}

foreach dir {tcl lang models views controllers modules templates} {
	foreach method {POST HEAD GET} {
		ns_register_proc $method /$dir/*  notFoundUrl
	}
}
proc notFoundUrl {} {
	ns_return 404 text/html "<h1>Couldn't find what you where searching for</h1>"
}
#Use this when we'll be able to use it at init
#foreach server [glob -type d [ns_server serverdir]/* ] {
#	append server /www
#
#	if {[file tail $server]=="lostmvc"} { puts "No model, controller or modules loading for $server " ; continue }
   #}
   #TODO load only which things are required.. create a special function for that.. 
   #TODO maybe tcl unknown can load this..?
apply {{} {
#	defineLanguages
#	set server [ns_pagepath];#For when loading tcl/init within each request	
	puts "\n=-=-=-=-\n pagepath  [ns_pagepath] and adp_dir [ns_adp_dir] pagedir [ns_server pagedir] serverdir [ns_server serverdir]\n=-=-=-=-=\n"
	#		set server [ns_server serverdir];#For at server startup loading
	foreach server [glob -type d [ns_server serverdir]/* ] {
		append server /www

		if {[file tail $server]=="lostmvc"} { puts "No model, controller or modules loading for $server " ; continue }
		#Loading all models..
		set modelpath  "$server/models/*.tcl"
	#	includeFromPath $modelpath

		set controllerpath "$server/controllers/*.adp"
		includeControllerFromPath $controllerpath "" $server
		
		set modulepath "$server/modules/*"
		foreach folder [glob -nocomplain -type d -- $modulepath]  {
	#		set modelpath $folder/models/*.tcl
			set controllerpath $folder/controllers/*.adp
	#		includeFromPath $modelpath
			includeControllerFromPath $controllerpath $folder $server

		}

	}
}}




