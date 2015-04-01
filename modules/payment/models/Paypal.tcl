#Model
nx::Class create Paypal -superclass Model
	
	#Constructor is usefull..
	#however for models it's hard when creating an automatic subclass
	#Either create constructor and put all data in it in subclasses.. and use next
	# OR make no constructor and just use methods for attributes, alias.. etc
	# see how this works out
	:method init {} {
		set :attributes { 
			table paypal_payments
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				pay_id {
			
					unsafe {
						on all

					}



				}
				access_token {
					
				}
				description {
					
				}
				amount {
					
				}
				currency {
					
				}
				subscription {
					validation {
						string { on all }
					}	
				}
				payment_method {
				
				}
				creation_at {
				
				}
				payment_at {
					
				}
				user_id {
					
				}
				token {
					
				}
				payer_id {
				
				}
				execute_url {
					
				}
				state {
					
				}

			}
			relations {
				user {column user_id fk_table users fk_column id fk_value id}

			}

 }  
		set :alias { 
			id Id
			pay_id {Pay id}
			access_token {Access token}
			description Description
			amount Amount
			currency Currency
			subscription Subscription
			payment_method {Payment method}
			creation_at {Creation at}
			payment_at {Payment at}
			user_id {User id}
			token Token
			payer_id {Payer id}
			execute_url {Execute url}
			state State

 }
		next 
	}
}

