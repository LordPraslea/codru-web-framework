<%

my set :layout layout
$model bhtml [set bhtml [bhtml new]]
set title [$model get title]

dict set pageinfo title "$title "

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc Site]} "[my getUrl -controller site index]"}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]

dict set pageinfo menu "
	{  -url 1 -show [my hasRole adminPost] {[mc Update] [mc Post]} [my getUrl -controller cms update [list id $id]]}
	{  -url 1 -show [my hasRole adminPost] {[mc Delete] [mc Post]} [my getUrl -controller cms delete [list id $id]]}
"

#dict set pageinfo sidebar  [ns_adp_parse -file sidebar.adp   $model $bhtml]
dict set pageinfo author [$model get author]
set tags [$model showTags]
dict set pageinfo keywords [join [$model relations tags] ", "]
set description [ns_striphtml [ns_unescapehtml  [string range [$model get post] 0 250]]]

dict set pageinfo description $description
set returnto [ns_conn url]
if {[string length [ns_conn query]]} {
	append returnto ?[ns_conn query]
}
ns_session put returnto $returnto

if {[info exists infoalert]} {
	append article [$bhtml alert {*}$infoalert]
}
set status [$model get status]
if {$status == 2 && ![my verifyAuth]} {

#ns_puts [$bhtml htmltag h1 $title]
 append article [$bhtml tag h2 [mc "This blog post is accesible only to registered users. Please %s to view it." [$bhtml link  [mc {log in}]  [my getUrl -controller user login] ]]]
} else { 
$bhtml syntaxHighlighter 
$bhtml  addPlugin tclbrush {
	js { "/js/sh/shBrushTcl.js"  }
	js-min { "/js/sh/shBrushTcl.js"  }
}

append article [$bhtml htmltag -htmlOptions [list class "text-center"] h1 $title]
#set blog_meta "[beautifulDate [$model get creation_at]] by  [$bhtml link -controller blog  [$model get author] author [list author [$model get author]]]"
#set blog_meta "[$bhtml fa]fa-lg fa-calendar]  [beautifulDate [$model get public_at]] [mc by] [$bhtml fa fa-lg fa-user] 
#[$bhtml link -controller cms  [$model get author] author/[$model get author]] [$bhtml fa fa-lg fa-clock-o] [$model get reading_time] [mc minutes] "
#append blog_meta  [$bhtml tag -htmlOptions [list class ""] div "[$bhtml fa fa-lg fa-tag] [mc Tags]: $tags "]
set blog_meta ""
if { [my hasRole adminPost]} {
	set blog_meta [$bhtml link [mc "Update"]  cms/update [list id $id] ]
}
append article [$bhtml tag -htmlOptions "class blog-post-meta" div $blog_meta]

if {$status == 4 && ![my verifyAuth]} {
	set data [string range [$model get post] 0 500 ]
	append data  [mc "This is a 500 character free preview.."] <br>
	append data [$bhtml link [concat [$bhtml fa fa-book fa-lg] " " [mc "Login to view the full post"]]   [my getUrl -controller user login]] " [mc or] "
	append data [$bhtml  link [concat [$bhtml fa fa-laptop fa-lg] " " [mc "create a new account for free"]]   [my getUrl -controller user register]]
	append article [$bhtml tag div [ns_unescapehtml $data]]
} else {
	append article [$bhtml tag div [ns_unescapehtml [$model get post]]]
}


ns_puts "[$bhtml tag article $article] <hr>"

}


%>
