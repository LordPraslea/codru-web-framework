#Model
nx::Class create RoleItem -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	#
	# type  (0: operation,		1: task, 	2: role)
	# role = admin
	# operation: blog.post.create
	# task=> multiple operations 

	:method init {} {
		set :attributes { 
			table role_item
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				name {
					validation {
						string {
							on all

						}
						required {
							on all

						}

					}

				}
				type {
					validation {
						integer {
							on all
						}
						between-num {
							on all
							rule { 0 2}
						}
						required {
							on all

						}

					}

				}
				description {
					validation {
						string {
							on all

						}

					}

				}
				bizrule {
					safe { on all }
					validation {
						string {
							on {create update}

						}

					}

				}
				data {
					safe { on all }
					validation {
						string {
							on {create update}

						}

					}

				}

			}

 }  
		set :alias { 
			id Id
			name Name
			type Type
			description Description
			bizrule Bizrule
			data Data

 }
		next 
	}

	:public method getType {{id ""}} {
		set types [list Operation 0 Task 1 Role 2 ]

		if {$id == ""} {
			return 	$types
		} else {
			set type [lindex $types [lsearch $types $id]-1]
		#	puts "Ok type $type"
			return  $type
		}
		 
	}

	:public method createRoleItem {{-new 1} type name description {bizRule ""} {data ""}} {
		set ri [self] 
		if {$new} {
			set ri [RoleItem new] 
		}
		$ri set type $type name $name description $description bizrule $bizRule data $data
		$ri insert
		return $ri 
	}

	:public method createOperation { name description {bizRule ""} {data ""}} {
		:createRoleItem 0 $name $description $bizRule $data	
	}
	:public method createTask { name description {bizRule ""} {data ""}} {
		:createRoleItem 1 $name $description $bizRule $data	
	}
	:public method createRole { name description {bizRule ""} {data ""}} {
		:createRoleItem 2 $name $description $bizRule $data	
	}

	:public method addChild {child} {
		set ric [RoleItemChild new]
		if {[RoleItem info instances $child] == $child } {
			set child_id [$child get id]
		#puts "RBAC [$child info class] == ::RoleItem "
		} elseif {[string is integer $child] && $child != ""} {
			set child_id $child
		}	else {
		#	:findByPk -save 0
			dbi_0or1row -db [:db get]  "select id as child_id from role_item where name=:child"
		}

		if {[string is integer $child_id]} {
			$ric set parent_id [:get id] child_id $child_id
			return 	[$ric insert]
		}
	}

	:public method findRole {{-new 1 } name} {
		set ri [self]
		if {$new} {
			set ri [RoleItem new]
		}
		set criteria [SQLCriteria new -model $ri]
		$criteria add name $name
		if {[$ri findByCond  $criteria]} {
			return $ri
		}
	}
	
	
	
}

