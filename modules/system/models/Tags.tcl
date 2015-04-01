#Model
nx::Class create Tags -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table tags
			primarykey id
			sqlcolumns {
				id {
					validation {
						integer {
							on all

						}
						required {
							on all

						}

					}

				}
				tag {
					validation {
						required {
							on all

						}

					}

				}

			}

 }  
		set :alias { 
			id Id
			tag Tag

 }
		next 
	}
}

