#!/usr/bin/env tclsh

#This file helps creating new websites
#By creating the directory structure and pointing to everything needed..
#puts "argc: $argc \t argv: $argv \t argv0: $argv0 \n  "
global database

proc getDatabase {} {
	global database
	set controller [Controller new]
	$controller loadConfigFile
	if {[ns_cache_get lostmvc config.[getConfigName] config]} {
		set database [dict get $config database]
		return $database
	}
	
}
if {[info exists ::argv]} {
	getDatabase
}
proc help {} {
	puts "=-=-=-=-=-=-= LostMVC Command Line Utility =-=-=-=-=-=-=\n
NOTE: Most of these commands assume that your webserver is running on port 80 and you
	have issued the	install <domain> command and everything is set up correctly.
Commands:
	help - This info is shown
	install <domain> - Create a new LostmMVC (sub)domain
	update <domain> - Update an existing LostMVC domain with the newest settings
	model <domain> <database_table> <Model_Class_Name> - Install model for a database table. 
	url <domain> \[Module\]\[/\]<Controller/View> - Generates specific URL for existent module/controller. 
	crud <domain> <model> <controller_id> - Setup CRUD for an existing model
	rbac <domain> rbac/ra/ri/ric <extra info> - Setup RBAC, RoleAssignment\[ra\], RoleItem\[ri\] and RoleItemChild \[ric\].
	rbac <domain> <model> \[authenticated\] \[guest\] \[special\]
	module <domain> <module> - Install the module you want for the <domain>. 
	install_lostmvc - install LostMVC *This requires ROOT access or at least run it with SUDO

	List information:
	list <domain> controller - List all controllers
	list <domain> model - List all models
	list <domain> tables - List all database tables 
	list <domain> modules - List all existing modules
	List <domain> rbac \[rbac/ra/ri/ric\] - List all RBAC info
	"
}
proc switchCommands {args} {
	set command [lindex $::argv 0]
	switch -nocase -- $command {
		help {	help	}
		install { install 	}
		update { update 	}
		url {
			url	
		}
		crud { crud }
		model { model }
		rbac { rbac  }
		install_lostmvc { 
			file delete -force -- /opt/ns/tcl/lostmvc 
			file copy lostmvc/tcl /opt/ns/tcl/lostmvc 
			puts "Installed new LostMVC Tcl files"
		}
		module {
			lassign $::argv -> domain module	
			if {$::argc <= 2} { puts "Usage: module <domain> <module> "; exit }
			if {![file exists $domain]}  { puts "The $domain domain doesn't exist, try again" ; exit}
			if {![file exists lostmvc/modules/$module]}  { 
				puts "This module doesn't exist."
				puts [getModules] ; exit}
		
			file delete -force $domain/www/modules/$module
			file copy lostmvc/modules/$module $domain/www/modules/$module

			exec chgrp -R www-data $domain/	 
			exec chmod -R g+w $domain/	 
			puts "Installed $module in $domain/modules/$module"
		}
		list { listInfo }
		default { help }
	} 
}
#TODO CHANGE THSI
proc getModules {} {
	return "Available modules: \n\t[join [glob -type d lostmvc/modules/*] \n\t]"
}
proc listInfo {} {
	lassign $::argv -> domain type extra	
	if {$::argc <= 2} {
		puts "Correct usage for list is one of the following:\n
		list <domain> controller - List all controllers
		list <domain> model - List all models
		list <domain> tables - List all database tables 
		list <domain> modules - List all modules
		List <domain> rbac \[rbac/ra/ri/ric\] - List all RBAC info"
	}

}
proc sendToNaviserver {args} {
#This procedure sends data to naviserver
#Since we're in a commandline, we can't load nsdbi.so. 
# We have a problem when we want to talk to the domain's database.
#Thus we need a way to talk to the server. We have multiple options.
# 1. Connect to the nscp control interface
# 2. Connect to the database from the config file and do everything 
# 3. Create a security controlled adp file and use it
# 4. Create a specific url running a command that's always online 

#At the moment we'll use the 3d option, we copy the file to the correct folder
#Make it that you can only connect to it through 127.0.0.1  with a unique password and delete it when we're done!
}

proc model {args} {

#Connect to database for more info..
	puts [pwd]
	lassign $::argv -> domain table model	
	puts "$domain $table $model"
	if {$::argc <= 3} { puts "Usage: model <domain> <database_table> <Model_Class_Name>"; exit }
	if {![file exists $domain]}  { puts "The $domain domain doesn't exist, try again" ; exit}
	#send to lostmvcli.adp
	package require http

	puts [http::data [http::geturl http://$domain/tcl/lostmvcli.adp -query [http::formatQuery command model password getlucky model $model table $table ]]]
}
proc crud {} {
	lassign $::argv -> domain model controller	
	if {$::argc <= 3} { puts "Usage: crud <domain> <model> <controller>"; exit }
	if {![file exists $domain]}  { puts "The $domain domain doesn't exist, try again" ; exit}
	package require http

	puts [http::data [http::geturl http://$domain/tcl/lostmvcli.adp -query [http::formatQuery command crud password getlucky model $model controller $controller ]]]
}
proc rbac {} {
	lassign $::argv -> domain model authenticated guest special	
	if {$::argc <= 2} { puts "Usage: rbac <domain> <model> \[authenticated\] \[guest\] \[special\]"; exit }
	if {![file exists $domain]}  { puts "The $domain domain doesn't exist, try again" ; exit}
	package require http

	puts [http::data [http::geturl http://$domain/tcl/lostmvcli.adp -query [http::formatQuery \
	command rbac password getlucky model $model  authenticated $authenticated guest $guest special $special ]]]
}
proc url {args} {
	
	lassign $::argv -> domain  
	set urls [lrange $::argv 2 end]
	if {$::argc <= 2} { puts "Usage: url <domain> <url> .. ?url? "; exit }
	puts [generateUrl $urls $domain]
}
proc generateUrl {urls {domain ""}} {
	#This function only adds url's to existent modules or controllers..
	#To generate CRUD use the crud command
	if {$domain == ""} { set domain [ns_pagepath] }
	set page ""

	foreach url $urls {
		set module ""	
		set splitdata [split $url /]
		if {[llength $splitdata] == 3} {
			lassign $splitdata module controller view
		} elseif {[llength $splitdata] == 2}  {   
			lassign $splitdata controller view
		} else {
			append page "Wrong url format, must be either: controller/view or module/controller/view"
			return $page	
		}
		set ct [string totitle $controller]Controller.tcl
		set action [subst {
			method action[string totitle $view] {} {
				my render $view
			}
		}]
		set viewdata { <% ns_puts "Hello there!" %> }

		if {$module == ""} {
			set controllerfile $domain/www/controllers/$ct
			set viewfile $domain/www/views/$controller/$view.adp 
		} else {
			set controllerfile $domain/www/modules/controllers/$ct
			set viewfile $domain/www/modules/views/$controller/$view.adp 
		} 

		set ft [open $controllerfile r]
		set controllerdata [read $ft]
		close $ft
	
		set ft [open $controllerfile w]
		set data "$view { allow { users * } }"
		set newcontroller	[regsub {(dict create views { (.+) })} $controllerdata "\\1 \n\t\t\t $data"]
	#	puts $newcontroller
		#Get the last location this string
		set loc [string last \} $newcontroller]
		puts $ft	[string replace $newcontroller $loc $loc "\n$action \n\}"]

		close $ft
			
		puts "$viewfile and $controllerfile"
		set fv [open $viewfile  w]
		puts $fv $viewdata
		close $fv
 	}
	puts "Done with URL"
}
proc generateModel {table model {bhtml ""}} {
	set dirPermissions 0
	set errors ""
	#This function is not meant to be run from the commandline 
	#only from within generator.adp or lostmvcli.adp
	set sql "SELECT column_name,data_type,is_nullable,column_default 
	FROM information_schema.columns WHERE table_name=:table ORDER BY ordinal_position;" 

	dict set pr_stmt  table $table
	global database 
	set data [dbi_rows -db [getDatabase] -bind $pr_stmt  -result flatlist  $sql]
	#error if no data
	if {$data == ""} {
		append errors  "The $table table doesn't seem to exist\n"
		return $errors
	}

	#Get PrimaryKey Info
	set sql "	SELECT
	tc.constraint_name, tc.table_name, kcu.column_name, 
	ccu.table_name AS foreign_table_name,
	ccu.column_name AS foreign_column_name 
	FROM  	information_schema.table_constraints AS tc 
	JOIN information_schema.key_column_usage AS kcu
	ON tc.constraint_name = kcu.constraint_name
	JOIN information_schema.constraint_column_usage AS ccu
	ON ccu.constraint_name = tc.constraint_name
	WHERE constraint_type = :type  AND tc.table_name=:table;"
	dict set pr_stmt  table $table 
	dict set pr_stmt  type "PRIMARY KEY"
	global database
	set primary_keys [dbi_rows -db [getDatabase] -bind $pr_stmt  -result flatlist  $sql]

	set attributes [dict create table $table primarykey id sqlcolumns { }] 
	#Add validation, requirements and alias here
	#Validation Type extra ( on scenario | rule <extra rule> )
	foreach {column datatype null default} $data {

		dict set alias $column [string totitle [split $column _]]

		if {$column in $primary_keys} {
			dict set attributes sqlcolumns $column unsafe on all
			continue;
		}
		#validation interchanged true with all
		#because "all" means it will be validated everywhere
		switch -glob -- $datatype {
			integer { dict set attributes sqlcolumns $column validation integer on all }
			serial { dict set attributes sqlcolumns $column validation integer on all }
			bigint { dict set attributes sqlcolumns $column validation integer on all }
			smallint { dict set attributes sqlcolumns $column validation integer on all }
			numeric { dict set attributes sqlcolumns $column validation numerical on all }
			real { dict set attributes sqlcolumns $column validation numerical on all }
			decimal { dict set attributes sqlcolumns $column validation numerical on all }
			text { dict set attributes sqlcolumns $column validation string on all }
			citext { dict set attributes sqlcolumns $column validation string on all }
			inet { dict set attributes sqlcolumns $column validation string on all }
			USER-DEFINED { dict set attributes sqlcolumns $column validation string on all }
			timestamp* { dict set attributes sqlcolumns $column validation integer on all }
			default { puts "$datatype where? for $column !" ; dict set attributes sqlcolumns $column validation { $datatype "Not implemented yet!" } }
		}
		if {$null == "NO"} { dict set attributes sqlcolumns $column validation required on all}
		#
		#TODO default
		#
	}
	#This is for getting the foreign keys but you can use it to get everything 
	#if you remove constraint_type ..
	#
	dict set pr_stmt  table $table 
	dict set pr_stmt  type "FOREIGN KEY"
	global database
	set foreign_keys [dbi_rows -db [getDatabase] -bind $pr_stmt  -result flatlist  $sql]
	foreach {constraint table column fktable fkcolumn} $foreign_keys {

		set newcolumn [join [lrange [split $column _] 0 end-1] _]
		#	dict set attributes relations $newcolumn column $column
		#	dict set attributes relations $newcolumn table $table
		#	dict set attributes relations $newcolumn fk_table $fktable	
		#	dict set attributes relations $newcolumn fk_column $fkcolumn
		#	fk_value is actually the value you'd like to get.. it can be of course multiple things concatenated
		dict set attributes relations $newcolumn [list column $column fk_table $fktable fk_column $fkcolumn fk_value $fkcolumn]
	}

	#	append page [dict get $data values]
	#Making the model
	#
	set modelclass $model
	set splitmodel [split $modelclass /]
	puts "Splitmodel $modelclass"
	if {[llength $splitmodel] > 1} {
		set modelpath "[ns_pagepath]/modules/[lindex $splitmodel 0]/models" 
	puts "modelpath $modelpath"
		catch {

			file mkdir $modelpath
			if {$dirPermissions} {
				file attributes $modelpath -permissions 0664
			}
		}
		set modelclass [lindex $splitmodel 1]
	} else { set modelpath "[ns_pagepath]/models" }
	#	append page "Modelpath is $modelpath"

	if {$errors == ""} {

	#Create and add to file
		set modeltemplatefile [open [ns_pagepath]/templates/model.tcl r]
		set modeltemplate [read $modeltemplatefile]
		close $modeltemplatefile

		set modelfile [open $modelpath/${modelclass}.tcl w]
		#puts $modelfile [format $modeltemplate $modelclass  \n[dict_format $attributes]\n \n[dict_format $alias]\n ]
		puts $modelfile [format $modeltemplate $modelclass  \n[dictformat_rec $attributes \t\t\t \t]\n \n[dictformat_rec $alias \t\t\t \t]\n ]
		close $modelfile

		file attributes $modelpath/${modelclass}.tcl -permissions 0664
		set text "Created the file: $modelpath/${modelclass}.tcl"
		if {$bhtml != ""} {
			append page [$bhtml alert -type success $text ]
		} else { 
			append page $text
		} 

	} else { 
		if {$bhtml !=""} {
			append page "Some errors occured <br>" [$bhtml alert -type danger $errors ]
		} else { 
			append page "Some errors occured:\n" $errors
		} 

	}

	return $page
}



proc generateCrud {model controller {bhtml ""}} {
	set dirPermissions 0
	set errors ""

	#set modelname [string totitle [$generatormodel get model]] toTitle Everysecondmatters
	set modelname $model 
	set module ""
	#set controllername "[string totitle [$generatormodel get controller_id]]Controller"
	set controllername "[string totitle $controller ]"

	set splitmodel [split $modelname /]
	if {[llength $splitmodel] > 1} {

		set module [lindex $splitmodel 0]
		set modelname [lindex $splitmodel 1]
		set viewsloc [ns_pagepath]/modules/$module/views/[string tolower $controllername]
		set controllerloc [ns_pagepath]/modules/$module/controllers
		set modelloc [ns_pagepath]/modules/$module/models 

		set moduleViewLoc [ns_pagepath]/modules/$module/views/
		foreach dir "$viewsloc $controllerloc $modelloc" {

			catch {
				file mkdir $dir
				if {$dirPermissions} {
					file attributes $dir -permissions 0664
				}
			}

		}
	} else { 
	#Locations
		set viewsloc [ns_pagepath]/views/[string tolower $controllername]
		set controllerloc [ns_pagepath]/controllers
		set modelloc [ns_pagepath]/models 

		set moduleViewLoc [ns_pagepath]/views/
	}


	#Locations			
	set templateloc [ns_pagepath]/templates

	#Generate model from file... loading model first
	set modelfile $modelloc/${modelname}.tcl

	if {[file exists $modelfile]} {
	#	puts "Is $modelname object ? [info object isa object $modelname ]"
		if {![info object isa object $modelname]} {
			source $modelfile
		}
		#	puts "Is $modelname object ? [info object isa object $modelname ] Creating new model!"
		set model 	[$modelname new]
		#Get the all the columns
		set columns [dict keys [dict get  [$model getAttributes] sqlcolumns]]	

		#Create Files with everything in them
		# index view _view update create _form admin 
		# and menu (containing links Create, Manage(admin), List, View, Delete)
		# you generate controller page.. but don't forget to generate an Controller.adp too
		#puts "TemplateLOC! $templateloc"

		#Creating views for CRUD 
		file mkdir $viewsloc

		if {$dirPermissions} {
			file attributes $viewsloc -permissions 0664
		}	
		#	file attributes $viewsloc -permissions 0666
		#Also _view
		foreach file {form  view index  create update admin _view module_layout} {
			if {$file == "module_layout"} {
				set viewdir $moduleViewLoc 
				set saveFile ${controllername}_layout
			} else {
				set viewdir $viewsloc
				set saveFile $file
			}
		#		puts "Opening the following $templateloc/$file.adp"
			set tpl [ns_adp_parse -file $templateloc/$file.adp $columns]	
			set tplfile [open $viewdir/$saveFile.adp w]
			puts $tplfile $tpl
			close $tplfile
			file attributes $viewdir/$saveFile.adp -permissions 0664
			append created "Created $file.adp <br>\n"

		}




		append created "<br>\n"
		#creating controller based on template file..
		set controllertemplatefile [open $templateloc/controller.tcl r]
		set controllertemplate [read $controllertemplatefile]
		close $controllertemplatefile


		set cf [open $controllerloc/${controllername}Controller.tcl w]
		set cfdata [string map "%controller $controllername 	%modelName $modelname" $controllertemplate ]
		puts $cf $cfdata
		close $cf
		file attributes $controllerloc/${controllername}Controller.tcl -permissions 0664

		#Writing the Controller.adp file
		set controllertemplatefile [open $templateloc/controller.adp r]
		set controllertemplate [read $controllertemplatefile]
		close $controllertemplatefile

		set cf [open $controllerloc/${controllername}Controller.adp w]
		set cfdata [string map "%controller $controllername 	%modelName $modelname" $controllertemplate ]
		puts $cf $cfdata
		close $cf
		file attributes $controllerloc/${controllername}Controller.adp -permissions 0664


		append created "Created  ${controllername}Controller.tcl AND   ${controllername}Controller.adp <br>\n"
		#TODO last thing to generate is a .adp file like the controller but simple and that doesn't require using complex controllers
		set text "CRUD and Controller for the class $modelname have been generated with success!<br>\n$created"
		if {$bhtml !=""} {
			append page [$bhtml alert -type success $text ]
		} else { 
			append page $text
		} 


	} else { 
		set text "The model '$modelname' doesn't exist"
		if {$bhtml !=""} { append page [$bhtml alert -type success $text ] } else { append page $text } 

	}
	return $page
}
#TODO!


proc generateRBAC {modelname authenticated guest {bhtml  ""}} {
	set splitmodel [split $modelname /]
	if {[llength $splitmodel] > 1} {
		set module [lindex $splitmodel 0]
		set modelname [lindex $splitmodel 1]
	}
	#Create RBAC database and tcl-dict file
	#
	#Add To DataBase and a flat file!
	if {[info exists module]} {
		lappend rbac	[string tolower $module]
	}
	lappend rbac [string tolower $modelname]

	# #TODO inform it's already added to database.. 
	set r [RoleItem new]
	set testrbac "$rbac index"

	set criteria [SQLCriteria new -model $r]
	$criteria add name [join $testrbac .]

	set data [$r search -criteria $criteria "id" ] 
	puts "RBAC $testrbac and data is $data"
	if {[dict get $data  values] != ""} { append page "There already seems to be a RBAC for $rbac <br>\n"} else {	

	#List of things to add.. 
	#TODO in the future view all controller actions..
	#TODO and add them to the database.. or flat file
	#Name Type Description
		set rbac_list ""
		lappend  rbac_list 	index 0 [list $modelname  Index ]
		lappend  rbac_list 	view 0 [list $modelname View ]
		lappend  rbac_list 	create 0 [list $modelname Create ]
		lappend  rbac_list 	update 0 [list $modelname Update ]
		lappend  rbac_list 	delete 0 [list $modelname Delete ]
		lappend  rbac_list 	restore 0 [list $modelname Restore ]
		lappend  rbac_list 	admin 0 [list $modelname Admin ]

		foreach {name type description} $rbac_list {
			set r [RoleItem new]	
			set newrbac [join "$rbac $name" . ]
			$r set name $newrbac type $type description $description
			$r save
			#	puts "$newrbac is [$r get id]"
			#add to dict
			dict set rbac_dict role_item $newrbac [list type $type description $description ]
			#	dict set rbacdict role_item $newrbac "type $type description $description"

			if {[string match *$name* "index view"]} {
				lappend show [$r get id]
				#TODO add to rbac_item_child correctly..
				#	dict set  rbac_dict rbac_item_child  $newrbac [dict merge "a" [dict get $rbacdict rbac_item_child]]
			} else {
				lappend admin [$r get id]
			}
			$r destroy
		}
		#Add show $model
		set r [RoleItem new]	
		$r set name show$modelname type 1 description "Show $modelname"
		$r save
		foreach s $show {
			set ric [RoleItemChild new]
			$ric set parent_id [$r get id] child_id $s
			$ric save
		}
		#$r destroy

		#Add ADMIN RBAC
		set showid [$r get id]
		set r [RoleItem new]	
		$r set name admin$modelname type 1 description "Admin $modelname"
		$r save

		set ric [RoleItemChild new]
		$ric set parent_id [$r get id] child_id $showid

		foreach a $admin {
			set ric [RoleItemChild new]
			$ric set parent_id [$r get id] child_id $a
			$ric save
		}
		#Admin =1, authenticated = 2, guest=3
		#If these change, we need to search the database..
		#do it manually atm..
		#	set r [RoleItem new]
		#	set  [$r search -where [list name [join $testrbac .] ] "id" ] 
		
		#parent_id 1 = superadmin
		set ric [RoleItemChild new]
		$ric set parent_id 1 child_id [$r get id]	
		$ric save

		#parent_id 2 = authenticated
		if {$authenticated == "on"} {
			set ric [RoleItemChild new]
			$ric set parent_id 2 child_id $showid	
			$ric save
		}

		#parent_id 3 = guest
		if {$guest == "on"} {
			set ric [RoleItemChild new]
			$ric set parent_id 3 child_id $showid	
			$ric save
		}
		set text "Added RBAC for $modelname!\n"
		if {$bhtml !=""} { append page [$bhtml alert -type success $text ] } else { append page $text } 
	}

	return $page
}

proc install {} {
	set domain [lindex $::argv 1]
	if {$::argc <= 1} { puts "Usage: install <domain>"; exit }
	if {[file exists $domain]}  { puts "The $domain domain already exists. Try using update $domain " ; exit}
	puts "Installing domain $domain"
	file mkdir $domain/www
	puts "Setting group attributes for $domain to www-data "
	file attributes $domain/ -group www-data 
	file attributes $domain/www -group www-data 
	puts "Created $domain directory"
	foreach {folder} {img js css fonts} {
		file copy lostmvc/$folder $domain/www/$folder
		#	file attributes $domain/www/$folder -group www-data 
		puts "Copied $folder/ folder.. to $domain/$folder"
	}

	foreach folder {modules controllers models views sessions} {
		file mkdir $domain/www/$folder
		puts "Creating $domain/$folder folder "
	}

	#Copy Important Views
	set folder views
	foreach file {column2.adp layout.adp generator_layout.adp} {
		file copy lostmvc/$folder/$file $domain/www/$folder/$file
		#	file attributes $domain/www/$folder/$file -group www-data 
	}
	puts "Finished copying important Views"
	file copy lostmvc/index.adp $domain/www/	
	if {0} {
		#TODO create routes?
		#Copy Important Controllers
		set folder controllers/system
		file copy lostmvc/$folder $domain/$folder
		#foreach file {ProfiletypeController UserController UserprofileController} {
			#	foreach ext {tcl adp} {
				#		file copy lostmvc/$folder/$file.$ext $domain/$folder/$file.$ext
				#	}
		}
		puts "Finished copying important Controllers"

		#Copy Important Models
		set folder models
		foreach file {ProfileType.tcl Tags.tcl Users.tcl UserProfile.tcl} {
			file copy lostmvc/$folder/$file $domain/$folder/$file
		}
		puts "Finished copying important Models"
	}
	#Copy Important Modules
	#	foreach file {user/ profiletype/ userprofile/ column2.adp layout.adp} {
	#		file copy lostmvc/$folder/$file $domain/$folder/$file
		#	}
		#
	foreach module {system rbac} {
		set folder modules/$module
		file copy lostmvc/$folder $domain/www/$folder

		#	file attributes $domain/www/$folder -group www-data 
		puts "Finished copying $module Module"
	}

	puts "Copying all tcl files required"
	file copy lostmvc/tcl $domain/www/tcl

	puts "Copying templates..."
	file copy lostmvc/templates $domain/www/templates
	puts "Copying language files..."
	file copy lostmvc/lang $domain/www/lang
	#file attributes $domain/* -group www-data 

	#TODO determine how naviserver loads this
	#put a lostmvcinit.tcl file into modules/tcl and load it!
	#	puts "Copying all tcl files"
	#	file copy lostmvc/tcl $domain/tcl

	if {0} {
		puts "Setting up configuration..."
		puts "Enter your Postgresql database name:"
		gets stdin database
		puts "Database Username:"
		gets stdin username
		# Print the prompt
		puts  "Database password:"
		flush stdout
		# Read that password!  :^)
		gets stdin password

	}


	puts "Setting group attributes for $domain to www-data "

	exec chgrp -R www-data $domain/	 
	exec chmod -R g+w $domain/	 
	#	exec chown -R www-data $domain/	 
	puts "Enter nsdbi handle:\n"
	gets stdin database

	puts "You can now go to http://$domain/ (if you set up /etc/hosts or the domain correctly)  "
}
proc update {} {
	set domain [lindex $::argv 1]
	if {$::argc <= 1} { puts "Usage: Update <domain>"; return " Nah" }
	if {![file exists $domain]} { puts "Domain doesn't exist, use install $domain to create it" ; return "nah" }
	puts "Updating domain $domain.."
	
	foreach {folder} {img js css fonts} {
		file copy -force lostmvc/$folder $domain/www/$folder
		#	file attributes $domain/www/$folder -group www-data 
		puts "Copied $folder/ folder.. to $domain/$folder"
	}

	#modules controllers models views

	set folder views
	foreach file {generator_layout.adp} {
		file copy -force lostmvc/$folder/$file $domain/www/$folder/$file
		#	file attributes $domain/www/$folder/$file -group www-data 
	}
	puts "Finished copying important Views"

	puts "Updating modules"
	foreach module {system rbac} {
		set folder modules/$module
		file copy -force lostmvc/$folder $domain/www/$folder

		#	file attributes $domain/www/$folder -group www-data 
		puts "Finished updating $module Module"
	}

	puts "Updating  all tcl files required"
	file copy -force lostmvc/tcl $domain/www/tcl
	puts "Updating templates..."
	file copy -force lostmvc/templates $domain/www/templates

	puts "Setting group attributes for $domain to www-data "

	exec chgrp -R www-data $domain/	 
	exec chmod -R g+w $domain/	 
	#	exec chown -R www-data $domain/	 

	puts "Domain $domain updated successfully!  "
}
if {[info exists argv0]} {
	if { [info script] eq $::argv0 } {
	# puts {In main} ;# When loading from commandline
		switchCommands
	} 
}


proc setColours {} {
	set txtblk "\e\[0;30m"; # Black - Regular
	set txtred "\e\[0;31m"; # Red
	set txtgrn "\e\[0;32m"; # Green
	set txtylw "\e\[0;33m"; # Yellow
	set txtblu "\e\[0;34m"; # Blue
	set txtpur "\e\[0;35m"; # Purple
	set txtcyn "\e\[0;36m"; # Cyan
	set txtwht "\e\[0;37m"; # White
	set bldblk "\e\[1;30m"; # Black - Bold
	set bldred "\e\[1;31m"; # Red
	set bldgrn "\e\[1;32m"; # Green
	set bldylw "\e\[1;33m"; # Yellow
	set bldblu "\e\[1;34m"; # Blue
	set bldpur "\e\[1;35m"; # Purple
	set bldcyn "\e\[1;36m"; # Cyan
	set bldwht "\e\[1;37m"; # White
	set unkblk "\e\[4;30m"; # Black - Underline
	set undred "\e\[4;31m"; # Red
	set undgrn "\e\[4;32m"; # Green
	set undylw "\e\[4;33m"; # Yellow
	set undblu "\e\[4;34m"; # Blue
	set undpur "\e\[4;35m"; # Purple
	set undcyn "\e\[4;36m"; # Cyan
	set undwht "\e\[4;37m"; # White
	set bakblk "\e\[40m"   ;# Black - Background
	set bakred "\e\[41m"   ;# Red
	set bakgrn "\e\[42m"   ;# Green
	set bakylw "\e\[43m"   ;# Yellow
	set bakblu "\e\[44m"   ;# Blue
	set bakpur "\e\[45m"   ;# Purple
	set bakcyn "\e\[46m"   ;# Cyan
	set bakwht "\e\[47m"   ;# White
	set txtrst "\e\[0m"   ;# Text Reset
}
