nx::Class create LanguageController {
	:variable lang
	:variable urlLang 

	:public method getLang {} {
		return ${:lang}
	}

	:public method getLanguage {} {
		set langs "English en Română ro  Nederlands nl"
		return [lindex $langs [lsearch $langs ${:lang} ]-1]
	}


	# First verify session language, if none is set look at the cookie 
	#	If the language from cookie, or session is different than from the
	#	language of the url, show the url in the language user is on
	#	We select the first preferred language of the browser 
	#	if accept-language doesn't exist we set the default configuration language
	#
	#TODO If first time on site and no cookie..ask which language he'd like?
	:public method lang {{_urlLang na}} {
		set config [:loadConfigFile]
		set configlang [dict get $config lang]
		:changeLanguageUrl $configlang

		set lang [ns_session get lang [ns_getcookie lostmvc_lang $_urlLang]]

		if {$lang != $_urlLang && $_urlLang ne "na"} {
			set lang $_urlLang
		}
		
		:forceLanguage

		if {$lang == "na"} {
			set nc [ns_conn headers]

			set acceptLang [ns_set get $nc Accept-Language $configlang]
			set lang2 [split $acceptLang ,-]

			set lang [lindex $lang2 0]
			#TODO If first time on site and no cookie..ask which language he'd like?
		} 

		:setLangEverywhere $lang

		return $lang
	}

	:public method forceLanguage {} {
		foreach refVar {lang _urlLang config} { :upvar $refVar $refVar }
			
		if {[dict exists $config forceLanguage]} {
			set forceLanguage [dict get $config forceLanguage]

			set _urlLang $forceLanguage
			set lang $forceLanguage
		}
	}
	

	:method setLangEverywhere {lang} {
		msgcat::mclocale $lang

		set :urlLang $lang
		ns_session put urlLang $lang
		set :lang $lang

		set module [:getModule] 
	
		msgcat::mcload [ns_pagepath]/lang
		msgcat::mcload [ns_pagepath]/modules/$module/lang/ 

		set moduleLangFile [ns_pagepath]/modules/$module/lang/$lang.$module.msg 
		if {[file exists $moduleLangFile]} {
		#	source $moduleLangFile 
		}
	}

	:method forceMultiLingual {} {
		foreach refVar {urlv _urlLang url} { :upvar $refVar $refVar }
		#TODO make setting forceMultilingual, if it's true then redirect to multilingual page:)
		set config [ns_cache_get lostmvc config.[getConfigName]] 

		set forceMultilingual [dict get $config forceMultilingual]
		if {$_urlLang eq "na" && $forceMultilingual && $urlv ne "index.adp"} {
			set query ""
			if {[ns_conn query] != ""} {
				set query ?[ns_conn query]
			}
		#Don't force language redirect unless needed..
		#
			set redirecturl [ns_conn location]/${:lang}$url$query
			ns_returnredirect $redirecturl 
			#After redirecting the execution goes on, even if it's unwanted
			#Discovered bug when developing LifeBeyondApocalypse (multiple searches!)
			#return -level 100 0
			return 0
		}
		return 1
	}

	#TODO cache
	:public method generateLanguageLinks {bhtml} {
		#set languages  [encoding convertfrom utf-8 "English en Română ro  Nederlands nl"]
		set languages  "English en Română ro  Nederlands nl"
		set originalUrl [ns_conn url]
		foreach {language lang} $languages  {
			if {$lang != [:getLang]} {
				set url [regsub /[:getLang]/ $originalUrl /$lang/]
				lappend languageLinks [list -url 1 $language  $url?changeLang=$lang ]
			}
		}

		return [$bhtml dropdown -class dropup -nav 0 "[$bhtml fa fa-lg fa-globe] [concat [mc "Language "] [:getLanguage]] "   $languageLinks 	]
	}
	
	
	:public method changeLanguageUrl {{optionalLang en}} {
		if {[ns_conn method] == "GET" && [ns_queryexists changeLang]} {
			set supportedlang "en ro nl"
			set supportedlanguages "English Română Nederlands"

			set lang [ns_queryget changeLang $optionalLang]
			if {[lsearch $supportedlang $lang] == -1} { set lang $optionalLang }	
			#TODO if logged in save his choice OR set his choice in the database in profile:D	
			
			#Set the session, cookie & locale with the current correct language,  
			ns_session put lang $lang
			ns_setcookie -path / lostmvc_lang $lang 
			msgcat::mclocale $lang

		#	set infoalert [list -type success [mc "Your language settings have been changed to English"] ]
			return $lang
		}
	}

}

