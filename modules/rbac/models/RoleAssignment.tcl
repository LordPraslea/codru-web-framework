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
			primarykey {item_id user_id}
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
				options {column user_id fk_table users fk_column id fk_value username fk_function "concat(user_id,' ',item_id)" }

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

	:public method searchByName {item username} {
		set sql_select  "SELECT * from role_assignment
		WHERE  item_id=(select id from role_item where name=:item)
		AND user_id=(select id from users where username=:user)"

		dict set pr_stmt user $username
		dict set pr_stmt item $item
		set result [dbi_0or1row -db ${:db} -array data -bind $pr_stmt $sql_select ]
		
		:set {*}[array get data]
		return $result
	}

	:public method makeViewLink {options} {
		lassign $options user_id item_id
		set html [${:bhtml} link -controller roleassignment "Update" update "user_id $user_id item_id $item_id"]
		#puts "Generated html $html \n"
		return $html 	
	}
}

