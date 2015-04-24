#!/usr/bin/env tclsh
#LostMVC installation
package require nx

source lostshell.tcl
nx::Object create InstallLostMVC -object-mixin LostShell {

	:public object method install {} {
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
		set scriptLocation [file dirname [info script]]
		set configFileLocation $scriptLocation/lostmvc.config
		puts "Reading configuration file (for any download changes refer to $configFileLocation) "
		set configFile [open $configFileLocation r]
		set :configuration  [chan read $configFile]
		chan close $configFile

		set cores [exec	grep -c ^processor /proc/cpuinfo]
		dict set :configuration cores $cores
		dict set :configure scriptLocation $scriptLocation

		file mkdir lostmvctemp	
		cd lostmvctemp
		puts "Created lostmvctemp/ folder going to [pwd]"
	}

	#the exec >&@stdout command  allows us to capture bouth stdout and stderror to show it DIRECTLY to the user 
	# this happens in silence, no error is trown
	# The followign might be usefull if having problems
	# chan configure stdout -buffering none
	:object method installActiveTcl {{-bit:choice,arg=32|64 32}} {

	set confirm "Install ActiveTCL? (It's advised if you didn't already install it, so you can install extra tcl packages with teacup) " 
	if {![:terminal:confirm:continue -default y $confirm]} { return	}
	set confirm "32 or 64 bit version?"
	set bit  [:terminal:confirm:continue -default 32 -options [list 32 "32 bit" 64 "64 bit"]  $confirm]
	set fileurl 	[dict get ${:configuration} activetcl $bit ]

	:downloadExtractAndCD ActiveTCL $fileurl

	puts "Running the ActiveTcl installation (this will require root access):"
	exec >&@stdout  sudo ./install.sh
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
		puts "Configuring & Installing NaviServer "
		reset
		exec >&@stdout 	./configure --prefix=/opt/ns --with-tcl=/opt/ActiveTcl-8.6/lib/tcl8.6 --enable-symbols

		exec >&@stdout make -j [dict get ${:configuration} cores] 
		exec >&@stdout sudo make install

		puts "Setting user permissions"
		set nsuser naviserver
		sudo chown -R $nsuser /opt/ns/logs
		#Use /opt/ns/www or /home/$user/www ..? for users
		sudo chown -R $nsuser:$nsuser /opt/ns/www



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
		:downloadExtractAndCD  "Next Scripting Framework" $fileurl
		puts "Configuring and installing Next Scripting Framework"
		exec >&@stdout    ./configure --enable-threads --prefix=/opt/ns/ --with-tcl=/opt/ActiveTcl-8.6/lib/tcl8.6
		exec >&@stdout    make
		exec >&@stdout    make install-aol
		puts "Done installing Next Scripting Framework"

		cd [dict get ${:configuration} scriptLocation]

	}

	:object method installAndConfigurePostgreSQL {} {
		set confirm "Do you want to install and configure  PostgreSQL Server with libpq-dev support?" 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		puts "INstalling PostgreSQL webserver and libpq-dev "
		exec >&@stdout 	sudo apt-get install postgresql libpq-dev

		set password [:terminal:password:get "Configuring Postgresql, please enter a password for postgres (used for database and linux user with FULL ACCESS)"]
		exec >&@stdout 	sudo su postgres -c psql -c "ALTER USER postgres WITH PASSWORD '$password';"
		echo -e "$password\n$password\n" | passwd $username

		puts "Enter a username to be used for connecting to PostgreSQL (using something different than postgres is good for security):"
		gets stdin username
		set password [:terminal:password:get "Enter password for user $username"]
		puts "Creating role"
		exec >&@stdout 	sudo su postgres -c psql -c "	CREATE ROLE $username WITH LOGIN PASSWORD '$password' VALID UNTIL '2099-01-01';" 
		exec >&@stdout 	sudo su postgres -c psql -c " ALTER USER lostone WITH PASSWORD 'LostInSpacE';"
		#	exec >&@stdout 	sudo su postgres -c psql -c 


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

	:object method installLostMVC {} {
		set confirm "Install  LostMVC ?" 
		if {![:terminal:confirm:continue -default y $confirm]} { return	}
		file delete -force -- /opt/ns/tcl/lostmvc 
		file copy tcl /opt/ns/tcl/lostmvc 
		puts "Installed new LostMVC Tcl files"
	}


#TODO Finish and test
	:object method installDomain {{-username ""} {-password ""} domain} {
		set nsuser naviserver
		if {$username == ""} {
			set username $domain
			adduser $username
			#passwd $username
			echo -e "$password\n$password\n" | passwd $username
		}
		mkdir -p /opt/ns/www/$username/www
		sudo chown -R $username:$nsuser /opt/ns/www/$username
		#710 is better since it gives owner full power, group execute and the rest NOTHING.. so 
		#no one can access things
		#Running generator.adp you have to set permissions 770 temporarily till it writes data
		#then set it to 710 or 750 again
		sudo chmod -R 750 /opt/ns/www/$username
		
		#Add domain to hosts
		sudo echo "127.0.0.1 $username" > /etc/hosts
		#TODO add domain to BIND!

	}


}

InstallLostMVC install
