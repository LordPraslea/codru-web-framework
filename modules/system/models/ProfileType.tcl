#Model
nx::Class create ProfileType -superclass Model {

	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table profile_type
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
						in {
							on all
							rule {string email integer numerical}
						}

					}

				}
				required {
					validation {
						between-num {
							on all
							rule { 0 1}

						}

					}

				}

			}

		}  
		set :alias { 
			id Id
			name Name
			type Type
			required Required

		}

		next 
	}

	#TODO profiletype as string or integer
	#string = 1 .. etc
	:public method getProfileType {{type ""}} {
		set profiletype "String string Numerical numerical Integer integer E-mail email"
		if {$type != ""} {
			return [lindex $profiletype [lsearch $profiletype $type]-1]
		}
		return $profiletype
	}
}

