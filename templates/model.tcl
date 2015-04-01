#Model
nx::Class create %s -superclass Model {
	
	:method init {} {
		set :attributes { %s }  
		set :alias { %s }
		next 
	}
}
