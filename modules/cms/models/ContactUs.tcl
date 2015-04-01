#Model
nx::Class create ContactUs -superclass Model {
	
	:method init {} {
		set :attributes { 
			table contact_us
			primarykey id
			sqlcolumns {
				id {
					unsafe {
						on all

					}

				}
				user_id {
					unsafe { on all }
				}
				name {
					validation {
						required {
							on all

						}

					}

				}
				email {
					validation {
						required {
							on all
						}

					}

				}
				ip {

					unsafe { on all }


				}
				sent_at {
					unsafe { on all }

				}
				message {
					validation {
						required {
							on all

						}

					}

				}
				captcha {
					validation {
						captcha { on  { all } }
					}
				}

			}
			relations {
				user {column user_id fk_table users fk_column id fk_value id}

			}

 }  
		set :alias { 
			id Id
			user_id {User id}
			name Name
			email E-mail
			ip Ip
			sent_at {Sent at}
			message Message

 }
		next 
	}
}

