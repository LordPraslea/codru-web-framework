#Model
nx::Class create RecycleBin -superclass Model {
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table lostmvc_recyclebin
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				user_id {
					unsafe {
							on all

					}

				}		
				deleted_at {
					validation {
						string {
							on all

						}

					}

				}
				table_name {
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

 }  
		set :alias { 
			id Id
			deleted_at {Deleted at}
			table_name {Table name}
			data Data

 }
		next 
	}
}

