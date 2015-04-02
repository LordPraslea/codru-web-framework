
<%  nsv_set info begin_time [clock milliseconds]; %>
<% 
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
#Development loading init for every page with a cache or -nocache
#In production mode the server loads this..
ns_adp_include -tcl -nocache installer.tcl
if {[ns_conn peeraddr] != "127.0.0.1"} {
	ns_puts "You may only connect from localhost"
	return 
}

set bhtml [bhtml new]
set page ""
set dirPermissions 0
#puts [dbi_ctl default dbipg2]
#TODO make it so you can generate ... models/controllers/crud for MODULES
if {[ns_session get cangenerate] != "yes"} {
	set ps [ns_queryget gen_password ]
	if {$ps != "letmein7"} {
		set page "You need to provide a password before you can login.<br>"
set model [Model new -attributes {table gen sqlcolumns { password { validation { required true }  } } } -alias { password Password} ]
set f [Form new -formType normal -model $model -bhtml $bhtml]
set field password

	$f beginGroup 
	$f label $field
	$f input -type password $field 
	$f errorMsg $field
	$f endGroup $field 

$f submit [mc "Authenticate"] xsubmit "btn-block btn-lg" 

append page [$f endForm  -horizontal 0 -action "" -method post -id authors -class "col-sm-4"]
$f destroy
 
		ns_adp_include -nocache [ns_pagepath]/views/generator_layout.adp -title "LostMVC generator" -keywords  "" -bhtml $bhtml $page  
		ns_adp_return "end"
	} else { 
	puts "Generating session!"
		ns_session put cangenerate yes 
	}
}
if {[ns_queryexists a]} {

	set a [ns_queryget a default]
	if {$a == "model"} {


		append page [$bhtml htmltag h1  "Model generation!"]

		set attributes [dict create table Generator primarykey id sqlcolumns {
			table {
				validation { required true }
			}
			model_name {
				validation { required true }
			}
			guest {
				validation { string true }
			}
			authenticated {
				validation { string true }
			}
			special {
				validation { string true }
			}
		} ]
		set alias [dict creat table "Database Table" model_name "Model class name"]
		set generatormodel [Model new -attributes $attributes -alias  $alias]

		unset alias

		if  {[ns_conn method] == "POST" && [ns_queryexists xsubmit]} {

			append page "Ok generating this thingie ..<br>"
			set formdata [$generatormodel getQueryAttributes POST]
			append page "<br>formdata: $formdata<br>"
			set formerrors [$generatormodel validate]

			if {[llength $formerrors]  < 2} {

				if {$formdata == ""} { ns_puts "Empty" ; return "" }
		
					append page [generateModel [ns_unescapehtml [$generatormodel get table]]  [ns_unescapehtml [$generatormodel get model_name]] $bhtml]
			}
		}

		if {1} {
			set f [Form new -model $generatormodel -bhtml $bhtml]
			$f allErrors

			$f beginGroup 
			$f label table
			$f input table
			$f errorMsg table
			$f endGroup table

			$f beginGroup 
			$f label  model_name
			$f input model_name
			$f errorMsg model_name
			$f endGroup model_name

			$f add [$bhtml input  -type hidden a model] 
			$f submit "Generate Model" 
			append page [$f endForm -action "" -method post -id generator -class "col-sm-4"]

			$f destroy
		}

	} elseif {$a == "controller"} {
	#  Controller based on these views in controllers/controllerName.tcl
	#  Fields
	#  Controller ID
	#  Base Class
	#  Action ID's (separate by space, comma or colon)
	#  Code Template
		append page [$bhtml jumbotron "Controller generation" "This page is still in the TODO phase.."]
	} elseif {$a == "crud"} {
	#	CRUD + VIEWS in views/{modelName}/file
	# 		view index create update delete admin, 
	# 		this also generates the controller..
	# 		Fields:
	# 	Model class
	# 	Controller ID
		append page [$bhtml htmltag h1  "CRUD and Controller generation!"]


		set attributes [dict create table CrudGenerator sqlcolumns {
			model {
				validation { required true string true }
			}
			controller_id {
				validation { required true string true }
			}
		} ]
		set alias [dict creat model "Model" controller_id "Controller ID"]
		set generatormodel [Model new -attributes $attributes -alias   $alias]

		if  {[ns_conn method] == "POST" && [ns_queryexists xsubmit]} {

			set errors ""
			set formdata [$generatormodel getQueryAttributes POST]
			set formerrors [$generatormodel validate]

			if {[llength $formerrors]  < 2} {

				set modelname [ns_unescapehtml [$generatormodel get model]]
				append page [generateCrud $modelname [ns_unescapehtml [$generatormodel get controller_id]] $bhtml]
			}

		}	
		set f [Form new -model $generatormodel -bhtml $bhtml]
		$f allErrors

		$f beginGroup 
		$f label model
		$f input model
		$f errorMsg model
		$f endGroup model

		$f beginGroup 
		$f label  controller_id
		$f input controller_id
		$f errorMsg controller_id
		$f endGroup controller_id

		$f add [$bhtml input  -type hidden a crud] 
		$f submit "Generate CRUD" 
		append page [$f endForm -action "" -method post -id generator -class "col-sm-4"]

		$f destroy
		append page "CRUD ( Create Read Update Delete) !"
	} elseif {$a == "rbac"} {

		append page [$bhtml htmltag h1  "RBAC generation!"]
		#RadioBoxes yes/no
		#GUEST means the guest may view the "showModel"
		#Authenticated means he may view the showModel
		#Special means something special..
		set attributes [dict create table Generator primarykey id sqlcolumns {
			model {
				validation { required true }
			}
			guest {
				validation { string true }
			}
			authenticated {
				validation { string true }
			}
			special {
				validation { string true }
			}
		} ]
		set alias [dict creat  model_name "Model class name"]
		set generatormodel [Model new -attributes $attributes  -alias $alias]

		unset alias

		if  {[ns_conn method] == "POST" && [ns_queryexists xsubmit]} {
			set errors ""
			set formdata [$generatormodel getQueryAttributes POST]
			set formerrors [$generatormodel validate]
			
		# if get guest = on .. add show to guest..

		#ns_puts  "Guest is [$generatormodel get guest]"
		#	return "Stop"
			if {[llength $formerrors]  < 2} {

				if {$formdata == ""} { ns_puts "Empty" ; return "" }
					append page [generateRBAC 	[ns_unescapehtml [$generatormodel get model]] [$generatormodel get authenticated] [$generatormodel get guest] $bhtml]
 
				}
		}
		#TODO you get the model, but you also need the controller..	
		set models [join [getAllModels 1] ", "]
		set f [Form new -model $generatormodel -bhtml $bhtml]
		$f allErrors

		$f beginGroup 
		$f label model
		$f add {<style> #generator_model { width: 300px;} </style>}
		$f input -options {maximumSelectionSize: 1} -type select2  model  $models
		$f errorMsg model
		$f endGroup model

		
		set type guest
		#$f add [$bhtml checkbox $type $type]
		$f checkbox $type
		
		set type authenticated
		$f checkbox $type 

		set type special
		$f checkbox $type
		
	#	$f radio eye "Green"
	#	$f radio eye "Blue"

		$f add [$bhtml input  -type hidden a rbac] 
		$f submit "Generate RBAC" 
		append page [$f endForm -action "" -method post -id generator -class "col-sm-4"]

		$f destroy
		append page "RBAC ( Role Based Access Control) !"
	} else {

		append page "Welcome to the Generator, select something from the menu"
	}

}
# All based on MODEL
# Regenerate this each time, or generate it once..(runonce)
#
# append page " <br> Time for request [expr {[clock milliseconds]-[nsv_get info begin_time]}] "
ns_adp_include -nocache [ns_pagepath]/views/generator_layout.adp -title "LostMVC generator" -keywords  "" -bhtml $bhtml $page  

ns_puts " <br> Time for request [expr {[clock milliseconds]-[nsv_get info begin_time]}] "
%>
