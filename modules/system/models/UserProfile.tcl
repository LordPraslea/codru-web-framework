#Model
nx::Class create UserProfile -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table user_profile
			primarykey {user_id profile_id}
			sqlcolumns {
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
				profile_id {
					validation {
						integer {
							on all

						}
						required {
							on all

						}

					}

				}
				profile_value {
					validation {
						string {
							on all

						}
						required {
							on all

						}

					}

				}

			}
			relations {
				profile {column profile_id fk_table profile_type fk_column id fk_value name}
				user {column user_id fk_table users fk_column id fk_value username}

			}

 }  
		set :alias { 
			user_id {User id}
			profile_id {Profile id}
			profile_value {Profile value}

 }
		next  
	}
}

