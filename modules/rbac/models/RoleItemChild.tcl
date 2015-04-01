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

	:public method getItems {} {

		set sql_size "SELECT count(role_item_child.*) as size FROM role_item_child " 
		#goldbag.id as Tags so we can reselect the tags.. disable/enable as needed! 
		set sql_select " SELECT ri1.name as parent, ri2.name as child 
FROM role_item_child , role_item ri1, role_item ri2
WHERE role_item_child.parent_id=ri1.id 
AND role_item_child.child_id=ri2.id"

		#TODO CACHE THIS
	#	set values  [dbi_rows -db [my getDb] -columns columns -bind $pr_stmt $sql_select ]
		#return [dict create columns $columns values $values size $size]
	#	puts "SQL is $sql_select begin_date $begin_date end_date $end_date"
		return [dict create sql_select  $sql_select pr_stmt "" sql_size $sql_size]
	}
}

