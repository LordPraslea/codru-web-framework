

<%
#TODO make one view for cms and blog post.. just use the $model get cms variable to know how to differentiate..

set title [$model get title]

dict set pageinfo title "United Brain Power - $title"

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "/"}
			{-url 1 {[mc Blog]} "[my getUrl index]"}
			{-active 1 "$title"}
	} ]  
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc Post]} [my getUrl index]}
	{  -url 1 -show [my hasRole adminPost]   {[mc Create] [mc Post]} [my getUrl -controller site create]}
	{  -url 1 -show [my hasRole adminPost] {[mc Update] [mc Post]} [my getUrl -controller site update [list id $id]]}
	{  -url 1 -show [my hasRole adminPost] {[mc Delete] [mc Post]} [my getUrl -controller site delete [list id $id]]}
	{  -url 1 -show [my hasRole adminPost]   {[mc Admin] [mc Post]} [my getUrl -controller site admin]}
	{  -url 1 -show [my hasRole adminPost]   {[mc Admin] [mc Comments]} [my getUrl -controller comment index]}

"

dict set pageinfo sidebar  [ns_adp_parse -file sidebar.adp   $model $bhtml]
dict set pageinfo author [$model get author]
set tags [$model showTags]
dict set pageinfo keywords [join [$model relations tags] ", "]
set description [ns_striphtml [ns_unescapehtml  [string range [$model get post] 0 250]]]

dict set pageinfo description $description
puts "Description $description"
if {[$commentmodel get id] != ""} {
	append article [$bhtml alert -type success [mc "Your comment has been saved, it is due to review by a moderator."]]

}

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
 append article [$bhtml tag h2 [mc "This blog post is accesible only to registered users. Please %s to view it." [$bhtml link  [mc {log in}] /user/login ]]
} else { 
$bhtml syntaxHighlighter 

append article [$bhtml htmltag h1 $title]
#set blog_meta "[beautifulDate [$model get creation_at]] by  [$bhtml link -controller blog  [$model get author] author [list author [$model get author]]]"
set blog_meta "[$bhtml fa fa-lg fa-calendar]  [beautifulDate [$model get public_at]] [mc by] [$bhtml fa fa-lg fa-user] 
[$bhtml link -controller blog  [$model get author] author/[$model get author]] [$bhtml fa fa-lg fa-clock-o] [$model get reading_time] [mc minutes] "
append blog_meta  [$bhtml tag -htmlOptions [list class ""] div "[$bhtml fa fa-lg fa-tag] [mc Tags]: $tags "]
append article [$bhtml tag -htmlOptions "class blog-post-meta" div $blog_meta]

if {$status == 4 && ![my verifyAuth]} {
	set data [string range [$model get post] 0 500 ]
	append data  [mc "This is a 500 character free preview.."] <br>
	append data [$bhtml link [concat [$bhtml fa fa-book fa-lg] " " [mc "Login to view the full post"]]  /user/login] " [mc or] "
	append data [$bhtml  link [concat [$bhtml fa fa-laptop fa-lg] " " [mc "create a new account for free"]]  /user/register]
	append article [$bhtml tag div [ns_unescapehtml $data]]
} else {
	append article [$bhtml tag div [ns_unescapehtml [$model get post]]]
}
ns_puts "[$bhtml tag article $article] <hr>"
ns_puts [ns_adp_parse -file socialstuff.adp ]

 ns_puts [$bhtml tag h3 [concat [$bhtml fa fa-lg fa-comments] [mc "What do you think?"]]]

#TODO REPLY TO
#	ns_puts [$bhtml detailView $model  {id title slug post creation_at author_id update_at update_user_id public_at status} {post showHtml}]
 #LOAD COMMENTS..
 ns_puts [$commentmodel genComments [$model get id] ]
if {[my verifyAuth]} { 
	ns_puts [ns_adp_parse -file ../comment/form.adp ]
} else  {
	#TODO open modal..?:)
	set login [$bhtml link [concat [$bhtml fa fa-book fa-lg] " " [mc "Log in"]]  /user/login] 
	set register [$bhtml  link [concat [$bhtml fa fa-laptop fa-lg] " " [mc "create a new account for free"]]  /user/register]
	ns_puts [mc "%s or %s to post comments." $login $register ]
}

ns_puts {
	<meta property="fb:admins" content="UnitedBrainPower"/>

<!-- Scripts Start -->
<b:if cond='data:post.isFirstPost'>
<!-- Facebook -->
<div id='fb-root'> </div>
<script>(function(d, s, id) {
var js, fjs = d.getElementsByTagName(s)[0];
if (d.getElementById(id)) {return;}
js = d.createElement(s); js.id = id;
js.src = "http://connect.facebook.net/en_US/all.js#xfbml=1";
fjs.parentNode.insertBefore(js, fjs);
}(document,'script', 'facebook-jssdk'));
</script>
}
set server "[ns_conn location][ns_conn url]"
ns_puts "<div class='fb-comments' data-href='$server' data-width='500'></div>"
}
%>


