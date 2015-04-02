<%
#LostMVC CommandLine utility to be used from within the installer.tcl
#This provides functionality to be able to update database information..
#TODO at the moment only PostgreSQL
ns_adp_include -tcl -nocache installer.tcl
proc toreturn {text} {
	ns_return 200 text/html $text
	return -level 2 $text
}
if {[ns_conn peeraddr] == "127.0.0.1"} {
	set password "getlucky"
	set gpass [string trim [ns_queryget password]]
	set command [string trim [ns_queryget command]]
	if {$password != $gpass} {
		#toreturn 403  "Access denied"
		toreturn  "Access denied"
	}
set bhtml [bhtml new]
#	ns_puts "Ok, you have access!"
	switch -- $command {
		model { 
			foreach {key} {table model} { set $key [ns_queryget $key] }
			ns_puts	[generateModel $table $model  ]
		}
		crud { 
			foreach {key} {controller model} { set $key [ns_queryget $key] }
			ns_puts	[generateCrud  $model $controller ]
		}
		rbac { 
			foreach {key} {model authenticated guest special} { set $key [ns_queryget $key] }
			ns_puts	[generateRBAC  $model $authenticated $guest $special ]
		}
		default { ns_puts "No such command" }
	}
} else { ns_puts "Not authorised" }

%>
