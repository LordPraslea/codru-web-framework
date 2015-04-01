#Model
nx::Class create RoleAssignment -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table role_assignment
			sqlcolumns {
				item_id {
					validation {
						integer {
							on all

						}
						required {
							on all

						}

					}

				}
				user_id {
					validation {
						integer {
							on all

						}
						required {
							on all

						}

					}

				}
				bizrule {
					validation {
						string {
							on all

						}

					}

				}
				data {
					validation {
						string {
							on all

						}

					}

				}

			}
			relations {
				item {column item_id fk_table role_item fk_column id fk_value name}
				user {column user_id fk_table users fk_column id fk_value username}

			}

 }  
		set :alias { 
			item_id {Item}
			user_id {User}
			bizrule Bizrule
			data Data

 }
		next 
	}
}

