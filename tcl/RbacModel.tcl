##########################################
# RBAC Model 
##########################################

nx::Class create RbacModel {
	#####################
	#	RBAC Roles
	#####################
	#Load Roles From DATABASE	
	:public method loadRoles {{userid ""}} {
		if {$userid ==""} { set userid [ns_session get userid] }
		set sql_select "
		SELECT ri.name, ri.type, ri.description, ri.bizrule, ri.data
		FROM role_assignment ra, role_item ri
		WHERE ra.item_id=ri.id 
		AND user_id=:user_id"
		dict set pr_stmt user_id $userid 

		set values  [dbi_rows -db [:db get] -columns columns -bind $pr_stmt $sql_select ]
	}


}
