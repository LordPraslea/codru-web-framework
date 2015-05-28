#Model
nx::Class create RoleItemChild -superclass Model {

	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	#TODO verify if it really exists..
	:method init {} {
		set :attributes { 
			table role_item_child
			primarykey { parent_id child_id   }
			sqlcolumns {
				parent_id {
					validation {	
						integer {
							on all

						}
					}
				}
				child_id {
					validation {
						integer {
							on all

						}
					}
				}

			}
			relations {
				child {column child_id fk_table role_item fk_column id fk_value name 
		   		}
				parent {column parent_id fk_table role_item fk_column id fk_value name
				}

			}

		}  
		set :alias { 
			parent_id {Parent id}
			child_id {Child id}
			parent {Parent}
			child {Child}

		}
		next 
	}

	:public method searchByName {parent_id child_id} {
		set sql_select "SELECT parent_id,child_id from role_item_child
		WHERE 
		parent_id=(select id from role_item where name=:parent_id)
		AND child_id=(select id from role_item where name=:child_id)"
		dict set pr_stmt parent_id $parent_id
		dict set pr_stmt child_id $child_id
		set result [dbi_0or1row -db ${:db} -array data -bind $pr_stmt $sql_select ]
		
		:set {*}[array get data]
		return $result
	}
	

	:public method getItems {} {

		set sql_size "SELECT count(role_item_child.*) as size FROM role_item_child " 
		set sql_select " SELECT ri1.name as parent, ri2.name as child, concat( ri1.id , ' ', ri2.id) as options 
		FROM role_item_child , role_item ri1, role_item ri2
		WHERE role_item_child.parent_id=ri1.id 
		AND role_item_child.child_id=ri2.id"

		#TODO CACHE THIS
	#	set values  [dbi_rows -db [my getDb] -columns columns -bind $pr_stmt $sql_select ]
		#return [dict create columns $columns values $values size $size]
	#	puts "SQL is $sql_select begin_date $begin_date end_date $end_date"
		return [dict create sql_select  $sql_select pr_stmt "" sql_size $sql_size]
	}

	:public method makeViewLink {options} {
		lassign $options parent_id child_id
		set html [${:bhtml} link -controller roleitemchild "Update" update "parent_id $parent_id child_id $child_id"]
		#puts "Generated html $html \n"
		return $html 	
	}
	
}

