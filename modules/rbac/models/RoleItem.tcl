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
}

