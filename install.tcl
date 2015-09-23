#!/usr/bin/env tclsh
#LostMVC installation
package require nx

source [file dir [info script]]/lostshell.tcl
nx::Object create InstallLostMVC -object-mixin LostShell {

	:public object method install {} {
		if {[:jumpToFunction]} {

			:confirmStart
			:installationPrequisitories
			:installActiveTcl
			:installNaviServer 
			:installNextScripting
			:installAndConfigurePostgreSQL
			:installNaviServerModules
			:installLostMVC

			puts "LostMVC  and its prequisitories should be installed by now. Have fun!"
		}
	}

	:object method jumpToFunction {} {
		if {[info exists ::argv]} {
			if {$::argv != ""} {
				set :acceptAllDefault 0
				set firstWord [lindex $::argv 0]
				set secondToLastWord [lrange $::argv 1 end]
				:configurationSetup
				puts "Running $firstWord $secondToLastWord"
				if {[:info  lookup method $firstWord] != "" } {
					:$firstWord {*}$secondToLastWord 
				} else { puts "Sorry, the command $firstWord doesn't exist.. try using \"help\"" }
				return 0
			}
		}
		return 1
	}

	:object method help {} {
		set allMethods [:info lookup methods]
		puts "All methods: \n $allMethods"
	}

	:object method confirmStart {} {
		if {[colorterm]} { background black;  }
		set confirm "Hello, welcome to the LostMVC installation process." 
		set options [list 1 "Do a full install (accept all default things)" 2 "Let me confirm each step" 3 "No thanks (exit)"]
		set result [:terminal:confirm:continue -default 3 -options $options $confirm] 
		switch -- $result {
			1 { set :acceptAllDefault 1 }
			2 { set :acceptAllDefault 0 }
			3 { puts "Have a nice day!"; exit  }
		}
	}
	:object method installationPrequisitories {} {
	#Read configuration
		:configurationSetup
		:goToTempDir

	}

	:object method configurationSetup {} {
		set scriptLocation [file dirname [info script]]
		 if {$scriptLocation == "."} { 		set scriptLocation [pwd] }
		set configFileLocation $scriptLocation/lostmvc.config
		puts "Reading configuration file (for any download changes refer to $configFileLocation) "
		set configFile [open $configFileLocation r]
		set :configuration  [chan read $configFile]
		chan close $configFile

		set cores [exec	grep -c ^processor /proc/cpuinfo]
		dict set :configuration cores $cores
		dict set :configuration scriptLocation $scriptLocation
	}

	:object method goToTempDir {} {
		file mkdir lostmvctemp	
		cd lostmvctemp
		puts "Created lostmvctemp/ folder going to [pwd]"

	}

	#the exec >&@stdout command  allows us to capture bouth stdout and stderror to show it DIRECTLY to the user 
	# this happens in silence, no error is trown
	# The followign might be usefull if having problems
	# chan configure stdout -buffering none
	:object method installActiveTcl {} {

	set confirm "Install ActiveTCL? (It's advised if you didn't already install it, so you can install extra tcl packages with teacup) " 
	if {![:terminal:confirm:continue -default y $confirm]} { return	}
	set confirm "32 or 64 bit version?"
	set bit  [:terminal:confirm:continue -default 64 -options [list 32 "32 bit" 64 "64 bit"]  $confirm]
	set fileurl 	[dict get ${:configuration} activetcl $bit ]

	:downloadExtractAndCD ActiveTCL $fileurl

	puts "Running the ActiveTcl installation (this will require root access):"
	exec >&@stdout  sudo ./install.sh
	
	puts "Setting up shortcuts for ActiveTcl"
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/bin/tclsh8.6 /usr/bin/tclsh
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/bin/tclsh8.6 /usr/bin/tcl
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/bin/tkcon /usr/bin/tkcon
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/bin/teacup /usr/bin/teacup

		#library stuff
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/lib/teapot/ /usr/lib/teapot
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/lib/libtcl8.6.so /usr/lib
	exec >&@stdout 	sudo ln -fs /opt/ActiveTcl-8.6/lib/libtk8.6.so /usr/lib
	puts "ActiveTcl  installed successfully!"
	cd [dict get ${:configuration} scriptLocation]
}

#works only with tar.gz files at the moment..
##TODO Figure out .zip / .tar.gz .bzip etc files
	:object method downloadExtractAndCD {{-outputFile "" } {-folder ""} name fileurl} {
		puts "Downloading $name"
		#reconfirms and retries to download
		if {$outputFile != ""} {
			exec >&@stdout wget -c -O $outputFile $fileurl 
			set filename $output
		} else {
			exec >&@stdout wget -c  $fileurl 
			set filename [file tail $fileurl] 
		}

		puts "Extracting the archive file: "
		exec >&@stdout tar zxf $filename

		if {$folder == ""} {
			set folder [file rootname [file rootname $filename]]
		}
		cd $folder
	}

	:object method installTcl {{-bit:choice,arg=32|64 32}} {
		puts "Default installation goes with ActiveTcl type N to compile the latest stable Tcl version"

	}	

	:object method installNaviServer {} {
		set confirm "Download, Compile and Install  NaviServer? Webserver for running LostMVC. Default location /opt/ns" 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}

		set fileurl 	[dict get ${:configuration} naviserver webserver ]
		:downloadExtractAndCD  NaviServer $fileurl

		foreground green
		puts "Configuring & Installing NaviServer (with [dict get ${:configuration} cores]  cores)  "
		reset
		exec >&@stdout 	./configure --prefix=/opt/ns --with-tcl=/opt/ActiveTcl-8.6/lib/tcl8.6 --enable-symbols
		
		exec >&@stdout make -j[dict get ${:configuration} cores] 
		exec >&@stdout sudo make install

		puts "Setting user permissions"
		set nsuser www-data
		exec >&@stdout sudo useradd $nsuser
		exec >&@stdout sudo chown -R $nsuser /opt/ns/logs
		#Use /opt/ns/www or /home/$user/www ..? for users
		exec >&@stdout sudo chown -R $nsuser:$nsuser /opt/ns/www



		#Installing as a service
		set confirm "Do you want to install NaviServer as a service in init.d ?" 
		if {[:terminal:confirm:continue $confirm]} { 
			exec >&@stdout sudo cp [dict get ${:configuration} scriptLocation]/config/nsd /etc/init.d/
			exec >&@stdout sudo chmod +x /etc/init.d/nsd
			exec >&@stdout sudo update-rc.d nsd defaults
		}

		cd [dict get ${:configuration} scriptLocation]
	}

	:object method installNextScripting {} {
		set confirm "Download, Compile and Install  Next Scripting Framework ? (OO framework created by maintainers of NaviServer, required by LostMVC) " 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		set fileurl 	[dict get ${:configuration} nextscripting ]
		:downloadExtractAndCD  "Next Scripting Framework" $fileurl
		puts "Configuring and installing Next Scripting Framework"
		exec >&@stdout    ./configure --enable-threads --prefix=/opt/ns/ --with-tcl=/opt/ActiveTcl-8.6/lib/tcl8.6
		exec >&@stdout    make
		exec >&@stdout sudo    make install
		exec >&@stdout sudo    make install-aol
		puts "Done installing Next Scripting Framework"

		cd [dict get ${:configuration} scriptLocation]

	}

	:object method installAndConfigurePostgreSQL {} {
		set confirm "Do you want to install and configure  PostgreSQL Server with libpq-dev support?" 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		puts "INstalling PostgreSQL webserver and libpq-dev "
		exec >&@stdout 	sudo apt-get install postgresql postgresql-contrib libpq-dev
	


		set password [:terminal:confirmPassword "Configuring Postgresql, please enter a password for postgres (used for database and linux user with FULL ACCESS)"]
	
		exec >&@stdout 	sudo su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '$password';\""
		echo -e "$password\n$password\n" | passwd postgres

		puts "Enter a username to be used for connecting to PostgreSQL (using something different than postgres is good for security):"
		gets stdin username
		set password [:terminal:confirmPassword	 "Enter password for user $username"]
		puts "Creating role"
		exec >&@stdout 	sudo su postgres -c "psql -c \"	CREATE ROLE $username WITH LOGIN PASSWORD '$password' VALID UNTIL '2099-01-01';\" "
		exec >&@stdout 	sudo su postgres -c "psql -c \" ALTER USER lostone WITH PASSWORD 'LostInSpacE';\""
		#	exec >&@stdout 	sudo su postgres -c psql -c 
		#
		#Modifying peer to md5 ONLY AFTER we setup everything
		exec >&@stdout  sudo vim -c ":%s/\s\s\s\speer/\tmd5/" -c ":wq!" /etc/postgresql/9.3/main/pg_hba.conf
		exec >&@stdout  sudo service postgres restart
		puts "Modified peer to md5 in /etc/postgres/9.3/main/pg_hba.conf restarting postgres.."


	}

	:object method installNaviServerModules {} {
	#nsdbi
	#nsdbipg
	#nsssl
		set confirm "Download, Compile and Install the following NaviServer modules: \n nsdbi nsdbipg nsssl \n " 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}

		set fileurl 	[dict get ${:configuration} naviserver modules ]

		:downloadExtractAndCD  -folder modules "NaviServer Modules" $fileurl

		:installNaviServerModule:nsdbi
		:installNaviServerModule:nsdbipg
		:installNaviServerModule:nsssl
		#Optional
		set confirm "Install NaviServer nsdbimy MySQL module ?"
		if {[:terminal:confirm:continue -default n $confirm]} { :installNaviServerModule:nsdbimy }

		set confirm "Install NaviServer nsdbilite SQLite module ?"
		if {[:terminal:confirm:continue -default n $confirm]} { :installNaviServerModule:nsdbilite }
		puts "If you want to install anyother module you can just go to the modules folder and follow the compilation instructions"

		cd [dict get ${:configuration} scriptLocation]
	}
	
	:object method installNaviServerModule:nsdbi {} {
		cd nsdbi
		exec >&@stdout make NAVISERVER=/opt/ns
		exec >&@stdout sudo	 make NAVISERVER=/opt/ns install
		cd ..
	}
	
	:object method installNaviServerModule:nsdbipg {} {
		cd nsdbipg
		exec >&@stdout make NAVISERVER=/opt/ns PGINCLUDE=/usr/include/postgresql 
		exec >&@stdout sudo	 make NAVISERVER=/opt/ns   PGINCLUDE=/usr/include/postgresql install
		cd ..
	}

	:object method installNaviServerModule:nsssl {} {
		cd nsssl
		exec >&@stdout make NAVISERVER=/opt/ns
		exec >&@stdout sudo	 make NAVISERVER=/opt/ns install
		cd ..
	}
	#TODO nsdbimy
	#sudo apt-get install libmysqlclient-dev
	
	#TODO install new SSL certificate?
	:object method createNew {} {
		cd [dict get ${:configuration} scriptLocation]
		set confirm "Create new SSL certificate?" 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		exec >&@stdout sudo rm -rf /opt/ns/tcl/lostmvc	
		exec >&@stdout sudo cp -rf tcl /opt/ns/tcl/lostmvc	
		#file delete -force -- /opt/ns/tcl/lostmvc 
		#file copy tcl /opt/ns/tcl/lostmvc 
		puts "Installed new LostMVC Tcl files"
	}

	:object method installLostMVC {{-host ""} {-user ""}} {
		cd [dict get ${:configuration} scriptLocation]
	
		if {$host == ""} { set location "At location /opt/ns/tcl/lostmvc " } else {
			set location "At remote host $user@$host ? "
		}
		set confirm "Install  LostMVC  $location " 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		if {$host == ""} {
			exec >&@stdout sudo rm -rf /opt/ns/tcl/lostmvc	
			exec >&@stdout sudo cp -rf tcl /opt/ns/tcl/lostmvc	
			exec >&@stdout sudo chown -R www-data:www-data  /opt/ns/tcl/lostmvc	
			#file delete -force -- /opt/ns/tcl/lostmvc 
			#file copy tcl /opt/ns/tcl/lostmvc
		} else {
			#exec  rsync -ave ssh --rsync-path=sudo\ rsync /opt/ns/www/lostmvc/tcl/ $user@$host:/opt/ns/tcl/lostmvc/
			exec >&@stdout  rsync -ave ssh --rsync-path=sudo\ rsync  /opt/ns/www/lostmvc/tcl/  $user@$host:/opt/ns/tcl/lostmvc/
		
		#	exec >&@stdout  ssh -t $user@$host "sudo cp -R lostmvc /opt/ns/tcl/lostmvc"
#			exec >&@stdout sudo chown -R www-data:www-data  /opt/ns/tcl/lostmvc	
		}

		puts "Installed new LostMVC Tcl files $location !"
	}
	
	:object method updateDomain { domain  } {
		cd [dict get ${:configuration} scriptLocation]
		set localLocation /opt/ns/www/$domain
		if {[file exists $localLocation/www]} {
			set config [:readConfigFile $localLocation/config ]
			foreach {k v} $config { set $k $v }
			exec >&@stdout  rsync -ave 'ssh -C' --rsync-path=sudo\ rsync   $localLocation/www $user@$host:$location
			puts "Done sync'ing the domain!"
				
		} else {
			puts "$domain doesn't seem to exist, sorry!"
		}
	}
	
	:object method readConfigFile { configFile } {
		if {[file exists $configFile]} {
				set file [open $configFile r]
				set data [read $file]
				close $file
				return $data
		} else {
			#Ask details and write to file!
			puts "No configuration file detected."
			
			dict set config host [:terminal:confirm "What hostname to connect to?"]
			dict set config user [:terminal:confirm "What username to use?"]
			dict set config location [:terminal:confirm "What's the location? Usually something like /var/www/$host/www"]
			dict set config modules [:terminal:confirm "Which modules to update?  "]

			set file [open $configFile w]
			puts $file $config
			close $file
			return $config
		}
	}


#TODO Finish and test
	:object method installNewDomain {{-username ""} {-password ""} domain} {
		set nsuser www-data
		set domainFolder /opt/ns/www/$domain 
	if {[file exists $domainFolder ]}  { puts "The $domain domain already exists. Try using update $domain " ; exit}
		if {$username == ""} {
			set username $domain
			exec >&@stdout	adduser $username
			#passwd $username
		 	exec >&@stdout sudo	echo -e "$password\n$password\n" | passwd $username
		}
		exec >&@stdout sudo mkdir -p $domainFolder/www

		exec >&@stdout sudo chown -R $username:$nsuser $domainFolder
		#710 is better since it gives owner full power, group execute and the rest NOTHING.. so 
		#no one can access things
		#Running generator.adp you have to set permissions 770 temporarily till it writes data
		#then set it to 710 or 750 again

		#Install Database
	
		#SWITCH BETWEEN BIND AND LOCAL HOSTS!
		#Add domain to hosts
		exec >&@stdout  echo "127.0.0.1 $domain"  | sudo tee --append /etc/hosts
		#TODO add domain to BIND!
		:copyDomainData $domainFolder

		exec >&@stdout sudo chown -R $username:$nsuser $domainFolder
		exec >&@stdout sudo chmod -R 750 $domainFolder

	}
	:object method copyDomainData {domain} {
		foreach {folder} {img js css fonts lang} {
			file copy [pwd]/$folder $domain/www/$folder
			#	file attributes $domain/www/$folder -group www-data 
			puts "Copied $folder/ folder.. to $domain/$folder"
		}

		foreach folder {modules controllers models views sessions templates tcl} {
			file mkdir $domain/www/$folder
			puts "Creating $domain/$folder folder "
		}

		#Copy Important Views
		set folder views
		foreach file {column2.adp layout.adp generator_layout.adp} {
			file copy [pwd]/$folder/$file $domain/www/$folder/$file
			#	file attributes $domain/www/$folder/$file -group www-data 
		}
		puts "Finished copying important Views"
		file copy [pwd]/index.adp $domain/www/	

		file copy [pwd]/tcl/config.adp $domain/www/tcl/config.adp

		foreach module {system rbac} {
			set folder modules/$module
			file copy [pwd]/$folder $domain/www/$folder

			#	file attributes $domain/www/$folder -group www-data 
			puts "Finished copying $module Module"
		}
	}


		:object  method module {args} {
			lassign $args domain module	
			if {$::argc <= 2} { puts "Usage: module <domain> <module> "; exit }
			if {![file exists /opt/ns/www/$domain]}  { puts "The $domain domain doesn't exist, try again [pwd]" ; exit}
			if {![file exists modules/$module]}  { 
				puts "This module doesn't exist."
				puts [:getModules] ; exit}

			set moduleLocation /opt/ns/www/$domain/www/modules/$module 
			file delete -force  $moduleLocation 
			file copy modules/$module $moduleLocation

			exec >&@stdout   sudo chgrp -R www-data $moduleLocation	 
			exec >&@stdout sudo  chmod -R g+w $moduleLocation
			puts "Installed $module in $domain/modules/$module"
		}
		:object method getModules {} {
			return "Available modules: \n\t[join [glob -type d modules/*] \n\t]"
		}


	}
if {[info exists argv0]} {
	if { [info script] eq $::argv0 } {
		InstallLostMVC install
	} 
}
