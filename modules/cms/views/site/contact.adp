<% 
set title [mc "Contact page"]
dict set pageinfo title   "United Brain Power - $title "
dict set pageinfo  keywords $title
dict set pageinfo breadcrumb " 
			{-url 1 {[mc Home]} {/site/index}}
			{-active 1 $title}
		"  

#set bhtml [bhtml new]

msgcat::mcmset en { 
	"Contact page" "Contact page"
}

msgcat::mcmset en { 
	"Contact page" "Contacteaza-ne"
}


if {[info exists infoalert]} {
	append page [$bhtml alert {*}$infoalert]
}
$model nodjsRules $bhtml
set f [Form new -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with <span class=\"required\">*</span> are requried."]]
$f allErrors

foreach field {name email message} type {input input textarea} {
	$f beginGroup 
	$f label $field 
	$f input -type $type   $field
	$f errorMsg $field
	$f endGroup $field 
}

	$f captcha
	
$f submit [mc "Submit"] xsubmit "btn-block btn-lg"
set url [ns_conn url]
if {[ns_conn query] != ""} { append url ?[ns_conn query] }
append form [$f endForm  -action $url -method post -id contact_us -class "col-sm-12"]

append page [$bhtml panel -h $title -type success -size col-sm-6 $form]
append page [$bhtml panel -h "Personalized offer?" -type info -size col-sm-6 "You can use the form to contact us.
We won't bore you with a 100 question form.<br>
If you require a personalized quote offer for any programming project please include the following information: <br>
Type of software. <br>
Functionality, what you actually need, what the software should do.<br>
Examples of sites/applications with similar information and functionalities <br>
"]


$f destroy

set page [encoding convertfrom utf-8 $page]


%>

