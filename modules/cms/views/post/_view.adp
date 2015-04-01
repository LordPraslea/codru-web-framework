<%
set article ""
set title [$model get title]
append article [$bhtml link  -controller blog [$bhtml htmltag h1 $title]  [$model get slug]]
set blog_meta "[$bhtml fa fa-lg fa-calendar]  [beautifulDate [$model get public_at]] [mc by] [$bhtml fa fa-lg fa-user] 
[$bhtml link -controller blog  [$model get author] author/[$model get author]] [$bhtml fa fa-lg fa-clock-o] [$model get reading_time] [mc minutes] "
append blog_meta  [$bhtml tag -htmlOptions [list class ""] div "[$bhtml fa fa-lg fa-tag] [mc Tags]: [$model showTags]"]
append article [$bhtml tag -htmlOptions "class blog-post-meta" div $blog_meta]
#TODO READ MORE THING!
set data [string range [$model get post] 0 500 ]
if {$status == 4 && ![ns_session contains userid]} {
	append data  [mc "This is a 500 character free preview.."] <br>
	append data [$bhtml link -controller user [$bhtml fa fa-book fa-lg][mc "Login to view the full post"]  /login] " [mc or] "
	append data [$bhtml  link -controller user [$bhtml fa fa-laptop fa-lg][mc "create a new account for free"]  /register]
} else {
append data "... " [my link -controller blog [$bhtml fa fa-book fa-lg][mc  "Continue reading.."] [$model get slug]]
}
append article [$bhtml tag div [ns_unescapehtml $data]]
#ns_puts [$bhtml tag div [ns_unescapehtml [$model get post]]]

#ns_puts [$bhtml tag -htmlOptions [list class blog-post-meta] div "x Comments last by y"]
ns_puts "[$bhtml tag article $article] <hr>"
%>


