##########################################
# RBAC Authentication and Authorization and Roles controller aid functions 
##########################################

nx::Class create AuthorizationRbac {

	##########################################
	#RBAC pre-action verification
	##########################################

	#Role Based Access Control
	:method preActionRbacType {} {
		:upvar access access verifyrbac verifyrbac 
		if {[dict exists $access rbac]} {
			set rbacvalue [string trim [dict get $access rbac]]
			#TODO differentiate between flat file and/or db.. first db
			switch $rbacvalue {
				database { set verifyrbac 1 }
				file { set verifyrbac 1}
				default { set verifyrbac 0 }
			}
		} 
		
	}	
	
	#Default is to deny everything that's not in thelist
	# User type verification
	#	* means everyone 
	#	@ means logged in/authenticated users
	#	anything else (default) means we verify the user 

	:method preActionVerifyAccess {} {
		foreach refVar {verifyrbac action access ok} { :upvar $refVar $refVar }
		if {$verifyrbac} {
			set ok	[my verifyRoles $action]
		} else {
			if {[dict exists $access views $action allow]} {
				set view [dict get $access views $action allow]

				:preActionVerifyUserAccess
				:preActionVerifyRoleAccess
			}
		}
	}
	
	:method preActionVerifyUserAccess {} {
		foreach refVar {view ok} { :upvar $refVar $refVar }

		if {[dict exists $view users]} {
			set users [dict get $view users]	
			foreach u $users {
				switch $u {
					* { set ok 1; break }
					@ { set ok  [my verifyAuthenticated] ; break }
					default { if {[set ok [my verifyUser $u]]} { break } }
				}
			}
		}
	}

	#Roles are verified after the users, since it may well be possibile that 
	#	the user isn't logged in:) 
	#	If roles exist, reset OK to 0 (untill validated!)
	:method preActionVerifyRoleAccess {} {
		foreach refVar {access action} { :upvar $refVar $refVar }

		if {[dict exists $access views $action roles]} {
			set ok 0
			set roles [dict get $access views $action roles]	
			foreach r $roles {
				#verify if user has this role..
				if {[set ok [my verifyRole $r]]} { break }	
			}
		}
	}

	#####################
	#	RBAC Roles
	#####################

	#Searching in the database for roles and verifying if they exist 
	#for the current rbac, or a "rbac" chosen by the developer
	# if usertype = authenticated and access = 0
	# 	show you're not allowed..
	# else if access => 1  allowed
	:public method loadRoles {rbac {returnLogin 1}} {
		set r [RoleItem new]
		set access 0
		#Cache time 10 minutes.. not too much can change in that time for the roles and/or auth stuff..
		set time 600
		set usertype guest ; #Default UserType

		:loadRolesData 
		:loadRolesGenealogy
		:loadRolesVerifyAuthenticatedRbac

		#Get RBAC for authenticated and/or guests.. and verify it	
		#set authguestvalues [dbi_rows -db [$r db get]  -bind $pr_stmt $select_recursive_rbac ]
		foreach $rbacGenealogyColumns $rbacGenealogyValues {
			if {$parent_name == $usertype} { incr access 1 ; break}
		}	

		#If usertype = guest and access = 0 #Redirect to login page
		if {$usertype =="guest" && $access == 0} {
			if {$returnLogin} {
				my returnLogin
			}
		} 

		return $access
	}
	
		
	#Search for the "id" of the current module.controller.view 
	# Load the guest and authenticated id (can be different in each application!)
	:method loadRolesData {} {
		foreach refVar {data guestid authid rbac time action_id r} { :upvar $refVar $refVar }

		set data [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.action_id.$rbac  { 
			$r search -where [list name $rbac ] "id"  
		}]
		set guestid [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.guestid  { 
			dict get  [$r search -where [list name "guest" ] "id" ] values
		}]
		set authid [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.authid  { 
			dict get  [$r search -where [list name "authenticated" ] "id" ] values
		}]

		if {$data == ""} { 
		#No data? Disallow!
			ns_log Warning "/!\\ WARNING /!\\ : No RBAC data found for \"$rbac\"!"
			return -level 2 0
		} else {
			set action_id [dict get $data values]
		}
		puts "Done in function loadRolesData"
	} 

	#Search all the possible descendants/parents of this current child # within the RBAC
	:method loadRolesGenealogy {} {
		foreach refVar {action_id r  cache time rbacGenealogyColumns rbacGenealogyValues} { :upvar $refVar $refVar }

		set select_recursive_rbac		{
			WITH RECURSIVE nodes(parent_id,parent_name,child_id,child_name,path,depth) AS (
			SELECT ric.parent_id, r1.name,
			ric.child_id,r2.name,
			ARRAY[ric.child_id],1
			FROM role_item_child AS ric, role_item AS r1, role_item AS r2
			WHERE 
			ric.child_id=:action_id AND
			r1.id=ric.parent_id AND r2.id= ric.child_id
			UNION ALL
			SELECT ric.parent_id, r1.name,
			ric.child_id,r2.name,
			path || ric.child_id, nd.depth+1
			FROM role_item_child AS ric, role_item AS r1, role_item AS r2, 
			nodes AS nd
			WHERE 
			ric.child_id = nd.parent_id AND
			r1.id=ric.parent_id AND r2.id= ric.child_id 
			) SELECT * from nodes;}
		dict set pr_stmt action_id $action_id 
		
		#Contains ALL parent/children history
		#even authenticated / guest ones!
		set cache [ns_cache_eval -timeout 5 -expires $time lostmvc loadRoles.recursive.$action_id  { 
			lappend return [dbi_rows -db [$r db get] -columns rbacGenealogyColumns -bind $pr_stmt $select_recursive_rbac ]
			lappend return $rbacGenealogyColumns
			return $return 
		}]

		lassign  $cache  rbacGenealogyValues rbacGenealogyColumns

	}

	:method loadRolesVerifyAuthenticatedRbac {} {
		foreach refVar {action_id access usertype rbacGenealogyColumns rbacGenealogyValues} { :upvar $refVar $refVar }

		#Select all the role assignments an user has
		if {[ns_session contains userid]} {
			set uservalues	[:loadRolesForUser [ns_session get userid]]

			#Verify roles for logged in user
			if {[lsearch $uservalues $action_id] != -1} { incr access 1 }
			foreach $rbacGenealogyColumns $rbacGenealogyValues {
				if {[lsearch $uservalues $parent_id] != -1} { incr access 1 }
			}

			#View if user has "superadmin" powers, give him 1
			#	if {[lsearch $uservalues "superadmin"] != -1} { incr access 1 ; puts "Whoa, we've got a superadmin! with values \n $uservalues\n" }
			set usertype authenticated

		#	puts "Done in function loadRolesVerifyAuthenticatedRbac currently authenticated access is $access"
		} 

		#	puts "Done in function loadRolesVerifyAuthenticatedRbac currently GUEST access is $access"
	}

	:method loadRolesForUser {userid} {
		:upvar 2 r r
		set sql_select "
			SELECT ri.id,ri.name
			FROM role_assignment ra, role_item ri
			WHERE ra.item_id=ri.id 
			AND user_id=:user_id"
		dict set pr_stmt user_id $userid 
		set uservalues  [dbi_rows -db [$r db get] -columns usercolumns -bind $pr_stmt $sql_select ]
		return $uservalues

		puts "Done in function loadRolesForUser uservalues $uservalues"
	}

	#	Verify All Roles
	:public method verifyRoles {action} {
		set module [my getModule]	
		set controller [my currentController]
		if {$module != ""} {
			lappend rbac $module 
		}
		lappend rbac $controller $action
		set rbac [join $rbac .]

		set roles [my loadRoles $rbac]
		return $roles
	}

	#Verify the role, while doing that see if the user is logged in..
	#if not then redirect to the login page
	# first verifies if role is function, runs it.. then continues
	#Verify first if there exists a function with this name
	:public method verifyRole {rolename} {
		if {[ns_session contains userid]} {

			set function $rolename
			if {[lsearch [: info lookup methods ] $function ] != -1} {
				return [my $function]
			} 
			return [my loadRoles $rolename]
		} else {

			return [my returnLogin]	
		}
	}


	:public	method getModule {} {
		#Gets the module needed for RBAC
		set module ""
		#	puts "Role Controller is adp info [ns_adp_info]"
		set v [split [ns_adp_info] /]
		if {[set loc [lsearch -nocase $v modules]] != -1} {
			set module [string tolower [lindex $v $loc+1]]
		}
		return $module
	}


	:public	method hasRole {rolename} {
		return [my loadRoles $rolename 0]
	}
}
