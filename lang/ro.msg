####################################### 
#Română
####################################### 
#User Model
msgcat::mcset ro  "This username doesn't exist" "Acest nume de utilizator nu există."
msgcat::mcset ro  "The password you entered is incorrect" "Parola specificată este incorectă." 
msgcat::mcset ro "Nice going sherlock, you've just temporarily blocked
					your account for 3 hours because you entered too many wrong passwords.." \
					"Bravo, tocmai ți-ai blocat contul temporar pentru 3 ore pentru că ai scris de prea multe ori parola greșită!"
msgcat::mcset ro  "You can't login because you're banned! If you think this is a mistake, contact us." "Acest cont este banat. Dacă crezi că acest lucru este o greșeală, contactează-ne"
msgcat::mcset ro  "This account is still temporarily blocked untill %s
				because someone tried too many wrong passwords.."   "Acest cont este blocat temporar pînă pe %s pentru că cineva a încercat prea multe parole greșite.."  


####################################### 
#System / User  Module
######################################## 

msgcat::mcmset ro { 
	"Account created successfully" "Cont creat cu succes" 
	"You've successfully registered. 
	You will recieve an e-mail with an activation link.
	Please click on it to activate your account and start saving time."
	"Te-ai înregistrat cu succes. 
	Vei primi un e-mail cu un link de activare.
	Apasa pe el ca sa-ți activezi contul și începe să salvezi timp." 
	"Your new account at %s" "Noul tău cont pe %s" 
	"Activation code incorrect." "Cod de activare incorect." 
	"No such activation code seems to exist" "Nu există un asemenea cod de activare" 
	"The code you've entered is incorrect, try again."
	"Codul introdus este incorect, încearcă din nou."
	"Account is already activated." "Contul tău este deja activat."
	"This account is already activated, you don't need to activate it again.." 
	"Acest cont este deja activat." 
	"You've successfully activated your account. You may now login!" "Ți-ai activat contul cu succes. Acuma te poti autentifica." 
	"No such username or e-mail can be found!" "Nici un utilizator sau adresa de e-mail nu poate fii gasita." 
	"A password reset has already been requested some time ago.
	You need to wait 3 hours between consequent password resets. Did you verify your e-mail? "
	"O resetare de parolă a fost efectuată acuma ceva timp. Trebuie sa astepti cel putin 3 ore între resetări consecvente. Ți-ai verificat e-mail-ul?"
	"You will recieve an e-mail with an password reset link.
	Please click on it to change your account's password." 
	"Vei primi un e-mail cu un link de reset al parolei..
	Da clic pe acel link ca să-ți schimbi parola." 
	"Resetting your password at %s" 
	"Parola resetata la %s" 
	"You've changed your password, you may now login!" 
	"Ti-ai schimbat parola, acuma te poti autentifica.!" 
	"Your password has been successfully changed." 
	"Parola ta a fost schimbata cu succes." 
	"This code doesn't exist" "Acest cod nu exista." 
	"Sorry this reset password code doesn't exist.." "Scuze, acest cod de resetare a parolei nu exista..."
	"Tried to search for id %d but just couldn't find it!" "Am încercat să caut articolul cu id-ul %d  dar nu există."  
	"Click here to restore it."	"Da clic pentru restituire."
	"Successfully deleted item with id  %d." "Articolul cu id-ul  %d a fost șters cu succes."

	"Keep me logged in for 48 hours. (This is a private computer)"
	"Ține-ma autentificat pentru 48 de ore. (Acesta este un calculator privat)"
}
msgcat::mcset ro "Not validating, sorry! %s" "Nu se validează scuze. %s" 
 

msgcat::mcmset ro {
	t:404notfound "404 Nu exista"
	p:404notfound "Nu am gasit ceea ce cauti. %s"
	"Something went a little wrong.." "Se pare că s-a întamplat ceva neasteptat..."
	"Error: %s Details: %s on line %d" "Eroare: %s Detalii: %s pe linie %d"
	t:unauthorized "Nu ești autorizat" 
	p:unauthorized 	"Scuze,  nu poti vedea această pagină. Ori nu ești autorizat, ori drepturile de acces sunt prea stricte."
}
######################################## 
#Validation and Database File
######################################## 
msgcat::mcmset ro {
	"%s is required" "Câmpul '%s' este necesar"
	"%s is required and cannot be empty" "'%s'este un câmp necesar si nu poate fi gol."
	"%1$s must not be %2$s" "%1$s trebuie să fie %2$s"
	"%1$s must be exactly %2$s" "%1$s trebuie să fie exact %2$s"
	"This doens't match what is required.." "Nu este conform cerintelor."
	"%s must contain a valid e-mail address." "%s trebuie să conțină o adresă de e-mail validă."
	"%1$s must be one of the following: %2$s" "%1$s trebuie să fie una din urmatoarele: %2$s"
	"%1$s is too long (maximum %2$s characters)" "%1$s este prea lung (maximum %2$s caractere)"
	"%1$s must be at least %2$s characters long" "%1$s trebuie sa fie  de cel putin %2$s caractere  lungime"
	"%1$s must be between %2$s and %3$s characters long" "%1$s trebuie să fie între %2$s si %3$s caractere lungime"
	"$%s must be an integer" "$%s trebuie să fie un număr întreg"
	"%s must be a number" "%s trebuie să fie un număr"
	"%1$s must be bigger than %2$s" "%1$s  trebuie să fie mai mare ca  %2$s"
	"%1$s must be smaller than %2$s" "%1$s trebuie să fie mai mic ca %2$s" 
	"Must be between number between %1$s and %2$s" "Trebuie să fie un număr între  %1$s și %2$s"
	"%1$s must be at least %2$d characters long" "%1$s trebuie să fie lung de cel putin %2$d caractere"
	"%1$s must be same as %2$s. These two fields don't seem too match" "Campul %1$s trebuie sa fie la fel ca %2$s"
	"%1$s must be unique. There already exists someone who uses %2$s" "%1$s trebuie să fie unic. Deja exista cineva care utilizează %2$s"
}


#Template VIEWS

msgcat::mcmset ro {
"Admin page for %s" "Pagina de administrare pentru %s"
"Creating new %s" "Crează un %s nou"  
"Create %s" "Crează %s"
"Index of %s" "Index-ul %s"
}


######################################## 
#Simple words
######################################## 
msgcat::mcmset ro {
	Search Cautare
	View Vezi
	Viewing Văzînd
	Delete Șterge
	Add	Adaugă 
	Edit Editează
	Update Actualizează
	Updating Actualizînd
	Admin Administrator
	Home Acasă
	Submit Trimite
	Register Înregistrare
	Login Autentificare

	Preview Previzualizare
	Next Urmatorul
	Complete Gata

	year an
	 month lună
	 week saptămână
	 day zi
	 hour oră
	 minute minut
	 second secundă 

	 years ani
	 months luni
	 weeks saptămâni
	 days zile
	 hours ore
	 minutes minute
	 seconds secunde 
		
	now acuma

	Tags Etichete
	by de
	or sau
	Share Împarte

	Username Utilizator
	Password Parola
	
	Create Crează
	
	Projects Proiecte
}
######################################## 
#Misc settings
######################################## 
msgcat::mcmset ro {
	"Per page" "Pe pagina"
"Fields with * are requried." "Câmpurile cu  <span class=\"required\">*</span> sunt necesare."
"Fields with <span class=\"required\">*</span> are requried." "Câmpurile cu   <span class=\"required\">*</span> sunt necesare."
	"Page %d from %d" "Pagina %d din %d"
	"There is no data available" "Nu există date la momentul de față."
	"No data has been found, try adding something!" "Nici o informație nu a fost găsită, încearcă să adaugi ceva!"
	"%1$s %2$s ago" "acum %1$s %2$s"

	{a %1$s ago} {acum o %1$s } 
	{a couple of %1$s ago} {acum cateva  %1$s } 
	{a few %1$s ago} {acum cateva %1$s }
}

######################################## 
#User View/Model
######################################## 

msgcat::mcmset ro {
	"User administration" "Administrarea Utilizatorului"
	"Change password" "Schimbă parola"
"List all users" "Vezi toți utilizatorii"
"Forgotten your password?" "Ți-ai uitat parola?"
"Create a new account" "Crează un nou cont"
 "Register - Create a new user" "Înregistrare - Crează un nou utilizator."
"By registering you agree to the terms and conditions." "Prin inregistrarea ta, ești de acord cu termenii si condițiile."
"I agree to the terms and conditions of this website." "Sunt de acord cu termenii și condițiile acestui website."
"Reset my password" "Resetează-mi parola."
"Reset forgotten password" "Resetează parola uitată"
"Updating User # %s" "Modificînd user-ul # %s"
"Viewing User # %s" "Vizualizînd utilizatorul # %s"
"log in" "Autentificare"
"Log In" "Autentificare"
"Log in" "Autentifică-te"
"You need to log in to view the page you're trying to access. (Your session has expired)."
"Trebuie să te autentifici pentru a avea acces. (Sesiunea ta a expirat)."
}
######################################## 
#Language settings
######################################## 
msgcat::mcmset ro  {
	"Change your language:" "Schimbați setarile de limbă:"
	"Your language settings have been changed to English" "Setarile dvs de limbă au fost schimbate pentru Română"
}
####################################### 
#BHTML / Generator 
####################################### 
msgcat::mcmset ro {
	"Toggle dropdown" "Lasă în jos"
	"Open Modal" "Deschide Modal-ul"
	"Enter the text in the image you see below" "Introdu text-ul care îl vezi în imaginea de mai jos."
	"Please correct the following errors:" "Te rog corecteaza urmatoarele erori:"

"This item has been restored from the Recycle Bin."
"Acest articol a fost restituit din Cosul de Reciclare."
 "Could not restore item from Recycle Bin with id %d.  Either the data has been fully deleted or there is no such data deleted." 
 "Nu am putut restitui articolul %d din cosul de Reciclare. Se poate că acesta a fost sters de tot sau nu există deloc." 
}


####################################### 
#Every Second matters
####################################### 
msgcat::mcmset ro {
	EverySecondMatters "Fiecare Secunda Contează"
	"Start at" "Început la"
	Pause Pauză
	Stop Oprește
	Continue Continuă
	Finished Terminat
}


####################################### 
#Personal Goldbag
####################################### 
msgcat::mcmset ro {
	"Fill in your expenses or income!" "Introdu cheltuielile sau veniturile!"
}

######################################## 
####################################### 
# Blog Post
#######################################

msgcat::mcmset ro {

	Draft Schiță
	"Published Public" "Publicat Public"
	"Published Authenticated" "Publicat Autentificat"
	Archived Arhivat 
	"Published Authenticated, Public preview" "Publicat autentificat, previzualizare publică"
	"Featured" "Recomandat"

	"This is a 500 character free preview.." "Acesta este o previzualizare libera de 500 caractere.."
	"Login to view the full post" " Autentifică-te ca să vezi post-ul intreg"
	"create a new account for free" " crează un nou cont gratuit"
	"Continue reading.." " Citește în continuare.."

	"Add Post" "Adauga Post-ul"
	"Add Comment" "Adauga Comentariu"
	
	"This blog post is accesible only to registered users. Please %s to view it."
	"Această postare este accesibilă doar utilizatorilor înregistrati. Te rugam %s  ca sa il vezi."  
	
	"Your comment has been saved, it is due to review by a moderator."
	"Acest comentariu a fost salvat, va fi publicat dupa ce un moderator îl citește."

	"What do you think?"	"Tu ce parere ai?"
	"%s or %s to post comments."
		"%s sau %s ca sa postezi comentarii"
	"Latest Posts" "Cele mai noi postări"
	"Latest Comments" "Cele mai noi comentarii"
	"Tag Cloud" "Nor de etichete"
}

msgcat::mcmset en { 
	"Contact page" "Contacteaza-ne"
}



