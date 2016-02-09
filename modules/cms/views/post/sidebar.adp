<%

#ns_parseargs { userid model bhtml } [ns_adp_argv]
ns_puts [ns_cache_eval -expires 600 lostmvc blog.sideBar.[getConfigName] {
	$model bhtml $bhtml
	set tagCloud [$model getTagCloud -firstId 0 -firstColumnName cms  1]
	#set htmlTagCloud [$bhtml table -bordered 1 -striped 1 -hover 1 [dict get $tagCloud columns] [dict get $tagCloud values]  ]
	set htmlTagCloud [$bhtml genTagCloud $tagCloud blog ]
	set head1 [$bhtml htmltag h3 [mc "Latest Posts"] ]  
	set posts [$model getLatestPosts 5] 
	
	set text1 [$bhtml well "$head1 $posts"]
	set head2 [$bhtml htmltag h3 [mc "Latest Comments"] ]  
	set head3 [$bhtml htmltag h3 [mc "Tag Cloud"] ]  
	#TODO TABS..?
	#
#	return "$text1 [$bhtml well $head2 ] [$bhtml well [concat $head3 $htmlTagCloud]] "
	lappend tabs [list [mc "Latest Posts"] $posts]
	lappend tabs [list [mc "Latest Comments"]  "comments later"]
	set return [$bhtml well [$bhtml tabs -pills 0  $tabs ]]
	append return [$bhtml well [concat $head3 $htmlTagCloud]]
	return $return


}]
%>
