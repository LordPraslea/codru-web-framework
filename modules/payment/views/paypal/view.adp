

<%

set title "Buying United Brain Power Subscriptions.."

dict set pageinfo title $title

		dict set pageinfo breadcrumb [subst {
			{-url 1 {[mc Home]} "#"}
			{-url 1 {[mc Payment]} /post/index}
			{-active 1 "$title"}
	} ]  

		if {0} {
	set id [$model get id]
dict set pageinfo menu "
	{  -url 1   {[mc List] [mc Post]} [my getUrl index]}
	{  -url 1   {[mc Create] [mc Post]} [my getUrl create]}
	{  -url 1   {[mc Update] [mc Post]} [my getUrl update [list id $id]]}
	{  -url 1   {[mc Delete] [mc Post]} [my getUrl delete [list id $id]]}
	{  -url 1 -show [my hasRole admin]   {[mc Admin] [mc Post]} [my getUrl admin]}
"
		}

ns_puts "You want to subscribe !"
ns_puts [ns_adp_parse -file form.adp ]
#	ns_puts [$bhtml detailView $model  {id title slug post creation_at author_id update_at update_user_id public_at status} {post showHtml}]

%>


