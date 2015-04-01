
<%
if {![$bhtml existsPlugin blogpost]} {
			$bhtml addPlugin blogpost { 
			js "/js/lostmvc/blogpost.js"
			js-min "/js/lostmvc/blogpost.js"
		}
	}
ns_puts {
<style>
#authors .form-group {
max-width:400px;
}
#cke_blog_post_post_backup {
 width:600px;
}

#blog_post_tags,#blog_post_originaltranslation_id {  width:350px; }
</style>
}
set f [Form new -formType normalex -model $model -bhtml $bhtml]
$f add [$bhtml htmltag -htmlOptions [list class help-block] p [mc "Fields with <span class=\"required\">*</span> are requried."]]
$f allErrors
	
set field title

	$f beginGroup 
	$f label $field 
	$f input   $field
	$f errorMsg $field
	$f endGroup $field 
	
set field slug

	$f beginGroup 
	$f label $field
	$f input $field
	$f errorMsg $field
	$f endGroup $field 
$f add "TODO: Upload image/file.. Automatic Gallery!<br>"

set field cms

	$f beginGroup 
	$f label $field
	$f add "&nbsp;"
	$f toggle -size normal -ontype primary -offtype success [mc "CMS"] [mc "Blog"] $field 
	$f errorMsg $field
	$f endGroup $field 

set field post

	$f label $field
	$f input -type ckeditor  $field 
	$f errorMsg $field
	
set field tags

	$f beginGroup 
	$f label $field
 #TODO LOAD TAGS
 set tags ""
	$f input -type select2  $field $tags	
		
	$f errorMsg $field
	$f endGroup $field 
	
set field public_at

	$f beginGroup 
	$f label $field
	$f input -type datepicker $field
	$f errorMsg $field
	$f endGroup $field 

set field originaltranslation_id

	$f beginGroup 
	$f label $field
set translation ""
	$f input -type select2  $field $translation	
	$f errorMsg $field
	$f endGroup $field 

set field language

	$f beginGroup 
	$f label $field
	$f select $field [$model language] 
	$f errorMsg $field
	$f endGroup $field 

	set field status

	$f beginGroup 
	$f label $field
	$f select $field [$model status] 
	$f errorMsg $field
	$f endGroup $field 
	

$f submit [expr {[$model isNewRecord]? [mc "Add Post"]: [mc "Update"]}]
set url [ns_conn url]
if {[ns_conn query] != ""} {
	append url ?[ns_conn query]
}
ns_puts [$f endForm  -action $url -method post -id authors -class "col-sm-12"]
$f destroy

%>


