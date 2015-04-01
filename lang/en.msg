#Self Contained language file
####################################### 
#English
####################################### 
#User Model
msgcat::mcmset en { 
	"This username doesn't exist" "This username doesn't exist"
	"The password you entered is incorrect" "The password you entered is incorrect" 
	"Nice going sherlock, you've just temporarily blocked your account for 3 hours because you entered too many wrong passwords.." \
		"Nice going sherlock, you've just temporarily blocked
	your account for 3 hours because you entered too many wrong passwords.." 
	"You can't login because you're banned! If you think this is a mistake, contact us." "You can't login because you're banned! If you think this is a mistake, contact us."
	"This account is still temporarily blocked untill %s because someone tried too many wrong passwords.."   "This account is still temporarily blocked untill %s because someone tried too many wrong passwords.."  
}

####################################### 
#System / User  Module
######################################## 

msgcat::mcmset en { 
	"Account created successfully" "Account created successfully" 
	"You've successfully registered. 
	You will recieve an e-mail with an activation link.
	Please click on it to activate your account and start saving time." "You've successfully registered. 
	You will recieve an e-mail with an activation link.
	Please click on it to activate your account and start saving time." 
	"Your new account at %s" "Your new account at %s" 
	"Activation code incorrect." "Activation code incorrect." 
	"No such activation code seems to exist" "No such activation code seems to exist" 
	"Account is already activated." "Account is already activated."
	"This account is already activated, you don't need to activate it again.." 
	"This account is already activated, you don't need to activate it again.." 
	"You've successfully activated your account. You may now login!" "You've successfully activated your account. You may now login!" 
	"No such username or e-mail can be found!" "No such username or e-mail can be found!" 
	"A password reset has already been requested some time ago.
	You need to wait 3 hours between consequent password resets. Did you verify your e-mail? "
	"A password reset has already been requested some time ago.
	You need to wait 3 hours between consequent password resets. Did you verify your e-mail? "
	"You will recieve an e-mail with an password reset link.
	Please click on it to change your account's password." 
	"You will recieve an e-mail with an password reset link.
	Please click on it to change your account's password." 
	"Resetting your password at %s" 
	"Resetting your password at %s" 
	"You've changed your password, you may now login!" 
	"You've changed your password, you may now login!" 
	"Your password has been successfully changed." 
	"Your password has been successfully changed." 
	"This code doesn't exist" "This code doesn't exist" 
	"Sorry this reset password code doesn't exist.." "Sorry this reset password code doesn't exist.."
	"Tried to search for id %d but just couldn't find it!" "Tried to search for id %d but just couldn't find it!"  
	"Click here to restore it."  "Click here to restore it." 
	"Successfully deleted item with id  %d." "Successfully deleted item with id  %d."
}
msgcat::mcset en "Not validating, sorry! %s" 

msgcat::mcmset en {
	t:404notfound "404 Not found, sorry :)"
	p:404notfound "Couldn't find the thing you were searching for. %s"
	"Something went a little wrong.." "Something went a little wrong.."
	"Error: %s Details: %s on line %d" "Error: %s Details: %s on line %d"
	t:unauthorized "You aren't authorized.." 
	p:unauthorized 	"Sorry, you can't view this page. 
	Either you are no authorized to access it or the user access rights for this page are too strict."
}
####################################### 
# Model.tcl / Validation 
######################################## 
msgcat::mcmset en {
	"%s is required" "%s is required"
	"%1$s must not be %2$s" "%1$s must not be %2$s"
	"%1$s must be exactly %2$s" "%1$s must be exactly %2$s"
	"This doens't match what is required.." "This doens't match what is required..TODO"
	"%s must contain a valid e-mail address." "%s must contain a valid e-mail address."
	"%1$s must be one of the following: %2$s" "%1$s must be one of the following: %2$s"
	"%1$s is too long (maximum %2$s characters)" "%1$s is too long (maximum %2$s characters)"
	"%1$s must be at least %2$s characters long" "%1$s must be at least %2$s characters long"
	"%1$s must be between %2$s and %3$s characters long" "%1$s must be between %2$s and %3$s characters long"
	"$%s must be an integer" "$%s must be an integer"
	"%s must be a number" "%s must be a number"
	"%1$s must be bigger than %2$s" "%1$s must be bigger than %2$s"
	"%1$s must be smaller than %2$s" "%1$s must be smaller than %2$s" 
	"Must be between number between %1$s and %2$s" "Must be between number between %1$s and %2$s"
	"%1$s must be at least %2$d characters long" "%1$s must be at least %2$d characters long"
	"%1$s is too long (maximum %2$d characters)" "%1$s is too long (maximum %2$d characters)"
	"%1$s must be same as %1$s. These two fields don't seem too match" "%1$s must be same as %1$s. These two fields don't seem too match"
	"%1$s must be unique. There already exists someone who uses %2$s" "%1$s must be unique. There already exists someone who uses %2$s"
}


#Template VIEWS

msgcat::mcmset en {
"Admin page for %s" "Admin page for %s"
"Creating new %s" "Creating new %s"  
"Create %s" "Create %s"
"Index of %s" "Index of %s"
}
####################################### 
# Simple words 
######################################## 
msgcat::mcmset en {
	Search Search
	View View
	Viewing Viewing
	Delete Delete
	Edit Edit
	Update Update
	Updating Updating
	Admin Admin
	Home Home
	Submit Submit
	Register Register
	Login Login

	Preview Preview
	Next Next
	Complete Complete

	year year
	 month month
	 week week
	 day day
	 hour hour
	 minute minute
	 second second 

	 years year
	 months month
	 weeks week
	 days day
	 hours hour
	 minutes minute
	 seconds second 
		
	now now

	Tags Tags
	by by
	Share Share
	
	Projects Projects

}
#Misc settings
msgcat::mcmset en {
	"Per page" "Per page"
"Fields with * are requried." "Fields with <span class=\"required\">*</span> are requried."
"Fields with <span class=\"required\">*</span> are requried." "Fields with <span class=\"required\">*</span> are requried."
	"Page %d from %d" "Page %d from %d"
	"There is no data available" "There is no data available"
	"No data has been found, try adding something!" "No data has been found, try adding something!"
	"%1$s %2$s ago" "%1$s %2$s ago"

	{a %1$s ago} {a %1$s ago} 
	{a couple of %1$s ago} {a couple of %1$s ago} 
	{a few %1$s ago} {a few %1$s ago}
}

#User View/Model

msgcat::mcmset en {
	"User administration" "User administration"
	"Change password" "Change password"
"List all users" "List all users"
"Forgotten your password?" "Forgotten your password?"
"Create a new account" "Create a new account"
 "Register - Create a new user" "Register - Create a new user"
"By registering you agree to the terms and conditions." "By registering you agree to the terms and conditions."
"Reset my password" "Reset my password"
"Reset forgotten password" "Reset forgotten password"
"Change password" "Change password"
"Updating User # %s" "Updating User # %s"
"Viewing User # %s" "Viewing User # %s"
"log in" "log in"

"Keep me logged in for 48 hours. (This is a private computer)"
"Keep me logged in for 48 hours. (This is a private computer)"

"I agree to the terms and conditions of this website."
"I agree to the terms and conditions of this website."
}
#Language settings
msgcat::mcmset en {
	"Change your language:" "Change your language:"
		"Your language settings have been changed to English" "Your language settings have been changed to English"
}
####################################### 
#BHTML / Generator 
####################################### 
msgcat::mcmset en {
	"Toggle dropdown" "Toggle dropdown"
	"Open Modal" "Open Modal"
	"Enter the text in the image you see below" "Enter the text in the image you see below"
	"Please correct the following errors:" "Please correct the following errors:"
}


####################################### 
#Every Second matters
####################################### 
msgcat::mcmset en {
	EverySecondMatters "Every Second Matters"
	"Start at" "Start at"
	Pause Pause
	Stop Stop
	Continue Continue
	Finished Finished
}


####################################### 
#Personal Goldbag
####################################### 
msgcat::mcmset en {
	"Fill in your expenses or income!" "Fill in your expenses or income!"
}

####################################### 
# Blog Post
#######################################

msgcat::mcmset en {

	Draft Draft
	"Published Public" "Published Public"
	"Published Authenticated" "Published Authenticated"
	Archived Archived 
	"Published Authenticated, Public preview" "Published Authenticated, Public preview"
	"Featured" "Featured"

	"This is a 500 character free preview.." "This is a 500 character free preview.."
	"Login to view the full post" " Login to view the full post"
	"create a new account for free" " create a new account for free"
	"Continue reading.." " Continue reading.."

	"Add Post" "Add Post"
	"Add Comment" "Add Comment"
	
	"This blog post is accesible only to registered users. Please %s to view it."
		"This blog post is accesible only to registered users. Please %s to view it."  
	
	"Your comment has been saved, it is due to review by a moderator."
		"Your comment has been saved, it is due to review by a moderator."

	"What do you think?"	"What do you think?"
	"%s or %s to post comments."
		"%s or %s to post comments."
}
