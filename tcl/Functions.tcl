#	 Different functions needed throughout the framework
#	 LostMVC version 1.0	 -	 http://lostmvc.unitedbrainpower.com
#    Copyright (C) 2014 Clinciu Andrei George <info@andreiclinciu.net>
#    Copyright (C) 2014 United Brain Power <info@unitedbrainpower.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
namespace eval lostmvc {

	proc Captcha {type {image "img.jpg"}}  {
		package require tclgd/

		set font [ns_server pagedir]/fonts/FreeSans.ttf
		#set font [file dirname [web::config script]]/gamesys/FreeSans.ttf
		set width 120 ; set height 40
		set img [GD create lol $width $height]

		set background [$img allocate_color 255 255 255] ; #background color

		#Lines
		set rl [rnd 0 200] ; set bl [rnd 0 200] ; set gl [rnd 0 200]
		set lineColor [$img allocate_color  100 200 220]
		for {set i 0} {$i<25} {incr i} {
		#set rl [rnd 0 200] ; set bl [rnd 0 200] ; set gl [rnd 0 200]
		#set lineColor [$img allocate_color $rl $bl $gl];# 100 200 220]

			set x1 [rnd 0 $width] ; set x2 [rnd 0 $width] ; set y1 [rnd 0 $height]  ;set y2 [rnd 0 $height]
			$img line  $x1 $y1 $x2 $y2 $lineColor 
		}
		#Text
		set r [rnd 0 200] ; set b [rnd 0 200] ; set g [rnd 0 200]
		#set textColor [$img allocate_color $r $b $g]
		set textColor [$img allocate_color 0 0 0]
		if {$type == "calc"} {	set text [humanTest] } else { 
			set text [generateCode 5 3] 
			ns_session put humanTest $text
			#	Session::cset humanTestAnswer $text
			#		Session::commit
		}
		$img text $textColor $font 20 0 [expr {round($width*0.4 - ([string length $text]*20*0.6)/2)} ]   [expr {round($height/2 + 20/2)} ]   $text

		# set HTTP header to "image/jpeg" instead of "text/html"
		#  web::response -set Content-Type image/jpeg

		#	set file [open $image w]
		# because we return a img, change to binary again
		#   fconfigure $file -translation binary -encoding binary

		# output
		#  puts $file [$img jpeg_data 90]
		ns_return 200 image/jpeg [$img jpeg_data 90]
	}


	proc generateCode {length {type 1}} {
		if {$type == 1} {
			set string "azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN0123456789"
		} elseif {$type == 2} { set string AZERTYUIOPQSDFGHJKLMWXCVBN0123456789 
		} elseif {$type == 3} { set string azertyuiopqsdfghjklmwxcvbn0123456789 
		} elseif {$type == 4} { set string AZERTYUIOPQSDFGHJKLMWXCVBN } else {  set string 0123456789 }
		set code ""
		set stringlength [expr {[string length $string]-1}]
		for {set i 0} {$i<$length} {incr i} {
			append code [string index $string [rnd 0 $stringlength]]
		}
		return $code
	}
	proc rnd {min max} {
		expr {int(($max - $min + 1) * rand()) + $min}
	}
	proc rndDouble {min max} {
		return [expr {($max - $min) * ( rand()  ) + $min}]
	}

	proc goodName {str} {
		return [string map  {Ț T ț t Ș S ș s Ă A ă a Î I î i Â A â a    Ş S ş s Ţ t ţ t  } $str]

	}

	proc makeGoodUrl {name} {
		set url [string tolower [goodName $name]]
		set url [regsub -all {[^A-Za-z0-9-]+} $url -]
		return $url
	}

	proc getHost {} {
		return [lindex [split [ns_conn location] /] 2]
	}
	proc getConfigName {} {
		return	[join [split [getHost] .] _]
	}
	#Name generation utilities in config/lista_nume.tcl
	#If you really want to generate names.. look into lista_nume.tcl
	proc generateName {} {
	#Generate random names that look plausible..
		set length [rnd 3 12]
		#1 = vocala, 2 = consoana.. cu ce incepe numele

		set vocale "aeiou"
		set consoane "qwrtpsdfghjklzxcvbnm"
		set lastChar ""
		set prelastChar ""

		set lastType 0 
		for {set var 0} {$var <= $length} {incr var} {
		# body...
			set current [rnd 0 1]
			if {$current} {
				incr lastType	
				if {$lastType>2} {
					set current 0; set lastType 0
				}
			} else { set lastType 0 }
			if {!$current} {
			#vocale
				set char [string index $vocale [rnd 0 [string length $vocale]]]
			} else {
			#consoane
				set char [string index $consoane [rnd 0 [string length $consoane]]]
			}
			append nume $char	
			set prelastChar $lastChar
			set lastChar $char

		}
		return [string totitle $nume]	

	}


	proc humanTest {} {
		set type [rnd 1 3]
		set nr1 [rnd 0 13]
		set nr2 [rnd 0 13]
		switch $type {
			1 { set operation "+" }
			2 { set operation "-" }
			3 { set operation "*" }
		}
		#set expr "<span style=\"background:lightgrey;color:green;\">$nr1 <span>$operation</span> $nr2</span>"
		set expr "$nr1$operation$nr2"	
		set answer [expr "$nr1 $operation $nr2"]
		ns_session put humanTest $answer
		#	Session::cset humanTestAnswer $answer
		#	Session::commit
		set returnexpr "$expr = ?"
		return $returnexpr
	}



	proc ns_queryencode {args} {
		set url ?
		set queryList {}
		foreach {key value} $args {
			lappend queryList [ns_urlencode $key]=[ns_urlencode $value]
		}
		append url [join $queryList &]
		if {[llength $args]>1} {
			return $url
		} else { return "" }
	}
	#Escapes HTML the correct way (quoting/unquoting even [])
	proc ns_escapehtml {value} {
	#Not updating "&" "&#38;" because it generates loops..
		set value [regsub -all  {<script[^>]*>.*<\/script>} $value ""]
		set value [regsub -all  {<iframe[^>]*>.*<\/iframe>} $value ""]
		set value [regsub -all  {<style[^>]*>.*<\/style>} $value ""]
		set value [regsub -all  {\s+on.{3,15}=} $value ""]

		#"/" "&#x2F;"
		if {0} {
			"oncontextmenu" "ignore"
			"ondblclick" "ignore"
			"onmousedown" "ignore"
			"onmouseenter" "ignore"
			"onmouseleave" "ignore"
			"onmousemove" "ignore"
			"onmouseover" "ignore"
			"onmouseout" "ignore"
			"onmouseup" "ignore"
		}
		#Most of the javascript enabled html attribtues begin with "on", so we just replace "on" with the ascii values:D
		# "on"  "&#111;&#110;"
		return [string map {
			"\"" "&#34;" 
			"'" "&#39;"
			"<" "&#60;"
			">" "&#62;"
			{[} "&#91;"
			{]} "&#93;"
		} $value ]
	}
	#Do this for things like ckeditor
	#TODO however eliminate <script> tags!
	#this function NEVER unescapes []!
	proc ns_unescapehtml {value} {
	#Not updating "&" "&#38;" because it generates loops..
	return [string map {
	"&#34;" "\"" 
	"&#x2F;" "/"
	"&#47;" "/"
	"&#39;" "'" 
	"&#60;" "<" 
	"&#62;"	">"
		"&#91;" {[}
	"&#93;" {]} 
} $value ]
		}
		if {0} {
			oo::objdefine bhtml method sanitize {value filter} {
				#This function should sanitize  ALL user input and transform it to the right  
				#sanitize URL
				#sanitize email  	Remove all characters except letters, digits and !#$%&'*+-/=?^_`{|}~@.[]. 
				#sanitize quotes 
				#sanitize float
				#sanitize int
				#sanitize special chars (html escape all htmlcharacters 
				#sanitize string   strip tags
				#sanitize allstring
				#Htmlencode to STRING
				for {set i 0} {$i < [string length $value]} {incr i} {
					set char [string index $value $i]
					scan $char %c ascii
					#&#93;
					#	puts "char: $char (ascii: $ascii)"
					append newvalue "&#$ascii;"
				}
				return $newvalue
			}
		}

		#from scanner.tcl to implement "sanitation"
		#very ingenious form of queryget .. sanitizing everything!
		proc safequeryget {varname datatype {defaultval ""}} {

			set tmpvar [ns_queryget $varname $defaultval]
			if {[string is $datatype -strict $tmpvar]} {
				return $tmpvar
			} 
			# for the datatype, scrub out non valid characters
			switch $datatype {
				"wordchar" {
					regsub -all { } $tmpvar {_} tmpvar
					regsub -all {[^A-Za-z0-9_]} $tmpvar {} tmpvar
					return $tmpvar
				}
				"alnum" {
					regsub -all {[^A-Za-z0-9]} $tmpvar {} tmpvar
					return $tmpvar
				}
				"alpha" {
					regsub -all {[^A-Za-z]} $tmpvar {} tmpvar
					return $tmpvar
				}
				"integer" {
					regsub -all {[^0-9]} $tmpvar {} tmpvar
					return $tmpvar
				}
			}
			return ""	
		}

		#Verifies if method is POST (default)
		#If we have a contentfile (spooler saved a temp file) our method is usually GET, we return 1
		# all other cases return 0
		proc ns_getcontentmethod {{method POST}} {
			if {[ns_conn method] == $method || [ns_conn contentfile] != "" } {
				return 1
			}
			return 0
		} 

		#Extracts the GET value of the QUERY using ns_queryget results
		#in either GET if it's GET or POST if it's a POST not both..
		#which complicates when you want to send a specific form
		#However there can be an alternative without mixing GET and POST
		#by just adding a hidden field to to that FORM with the ID
		# - name name of the GET parameter
		#
		proc ns_get {name} {

			set q [split [ns_conn query] "&="]
			if {[dict exists $q $name]} {
				return [dict get $q $name]
			} else { return "" }
		}

		proc ns_getallform {form key} {
			set result ""
			set alldata [ns_set array $form]
			set indices [lsearch -all $alldata $key] 
			foreach i $indices {
				lappend result [lindex $alldata $i+1] 
			}
			return $result
		}

		#Gets the content for the form if a spooler was used
		#It also copies the tempfile created..
		proc ns_getcontentform {} {
			set form ""
			set tmpfile [ns_conn contentfile]
			#If the content file is empty (thus not spooled, and under the maxupload limit)
			#we write the content to a temporary file.. so we can process it
			if {$tmpfile == "" } {
				set tmpfile [ns_mktemp /tmp/nscontent-XXXXXX]
				set cf [open $tmpfile w]
				ns_writecontent $cf
				chan close $cf
				ns_atclose [list file delete $tmpfile]
			}
			if {$tmpfile != ""} {
			#	set newtempfile [ns_mktemp [ns_pagepath]/uploads/up-XXXXXX]
			#	file copy -force -- $tmpfile $newtempfile
			#	file attributes $newtempfile -permissions 00644
				set form [ns_set create]
				ns_parseFormContentData $tmpfile $form [ns_set iget [ns_conn headers] content-type]
				#Atclose!
				#	ns_atclose [list file delete $newtempfile]
			}
			return $form
		}

		#Copy from tempfile to real a location we won't delete
		#In future add options to modify file before saving:D
		#RETURNS name of new files ...
		proc ns_manageUploadFiles {uploadLocation uploadFolder action} {
			foreach refVar {form fieldName} { upvar $refVar $refVar }
			set count [ns_set get $form $fieldName.count]
			catch {file mkdir $uploadLocation/$uploadFolder}
			set returnFiles ""

			for {set i 1} {$i <= $count} {incr i} {
				set filename [ns_set get $form $fieldName.$i.name]
				set tmpname [ns_set get $form $fieldName.$i.tmpfile]
				#Sometimes when the upload is empty, we have a "empty" tmpname with a empty filename
				if {[file size $tmpname] == 0 && $filename == ""} { continue }
				#	set savefile $uploadLocation/$filename
				#	puts "Copying from $tmpname ([file size $tmpname]) name $filename"
				#	file copy -force  -- $tmpname $savefile
				#	lappend returnFiles $filename

				lappend returnFiles [$action]

			}
			return $returnFiles
		}

		#First convert then save to database? Or the other way arround?
		#Seems that the imagemagick returns an error "unable to locate img"
		#even though it generates the images, tcl seems to say "child process exited abonrmally
		#so we surround it with a catch
		proc	ns_convertResizeImages {} {
			foreach refVar {tmpname filename uploadLocation uploadFolder} { upvar $refVar $refVar }
			set filename [join [file rootname $filename] _]

			catch { set result [exec  >&@stdout   convert  $tmpname -quality 85 -write mpr:img \
			   \( mpr:img  -thumbnail 1300x1300 -write $uploadLocation/$uploadFolder/l_$filename.jpg \) \
			   \( mpr:img -thumbnail 600x600 -write $uploadLocation/$uploadFolder/m_$filename.jpg  \) \
			   \( mpr:img -thumbnail 300x300 -write $uploadLocation/$uploadFolder/s_$filename.jpg \) \
		   -thumbnail 100x100 $uploadLocation/$uploadFolder/t_$filename.jpg]}

		   #We return the name of the large file then it's
		   #regexp time to rename /l_ to other things
			return $uploadFolder/l_$filename.jpg  
		}


		#Create temporary files from file (spooler or your own data file)
		proc ns_parseFormContentData { file form contentType } {

			if { [catch { set fp [open $file r] } errmsg] } {
				return
			}

			if { ![regexp -nocase {boundary=(.*)$} $contentType 1 b] } {
				return
			}

			fconfigure $fp -encoding binary -translation binary
			set boundary "--$b"

			while { ![eof $fp] } {
			# skip past the next boundary line
				if { ![string match $boundary* [string trim [gets $fp]]] } {
					continue
				}

				# fetch the disposition line and field name
				set disposition [string trim [gets $fp]]
				if { $disposition eq "" } {
					break
				}

				set disposition [split $disposition \;]
				set name [string trim [lindex [split [lindex $disposition 1] =] 1] \"]
				#File Count increasing
				if {[set fileCount [ns_set get $form $name.count]]  == "" } { 
					set fileCount 1
				} else { incr fileCount }
				ns_set update $form $name.count $fileCount

				# fetch and save any field headers (usually just content-type for files)

				while { ![eof $fp] } {
					set line [string trim [gets $fp]]
					if { $line eq "" } {
						break
					}
					set header [split $line :]
					set key [string tolower [string trim [lindex $header 0]]]
					set value [string trim [lindex $header 1]]

					ns_set put $form $name.$key $value
				}

				if { [llength $disposition] == 3 } {
				# uploaded file -- save the original filename as the value
					set filename [string trim [lindex [split [lindex $disposition 2] =] 1] \"]
					ns_set delkey $form $name.$key
					ns_set put $form $name $filename
					ns_set put $form $name.$fileCount.name $filename
					ns_set put $form $name.$fileCount.$key $value

					# read lines of data until another boundary is found
					set start [tell $fp]
					set end $start

					while { ![eof $fp] } {
						if { [string match $boundary* [string trim [gets $fp]]] } {
							break
						}
						set end [tell $fp]
					}
					set length [expr {$end - $start - 2}]

					# create a temp file for the content, which will be deleted
					# when the connection close.  ns_openexcl can fail, hence why 
					# we keep spinning

					set tmp ""
					while { $tmp eq "" } {
						set tmpfile [ns_mktemp]
						set tmp [ns_openexcl $tmpfile]
					}

					catch {fconfigure $tmp -encoding binary -translation binary}

					if { $length > 0 } {
						seek $fp $start
						chan copy $fp $tmp -size $length
					}

					close $tmp
					seek $fp $end
					ns_set put $form $name.$fileCount.tmpfile $tmpfile

					if { [ns_conn isconnected] } {
						ns_atclose [list file delete $tmpfile]
					}

				} else {

				# ordinary field - read lines until next boundary
					set first 1
					set value ""
					set start [tell $fp]

					while { [gets $fp line] >= 0 } {
						set line [string trimright $line \r]
						if { [string match $boundary* $line] } {
							break
						}
						if { $first } {
							set first 0
						} else {
							append value \n
						}
						append value $line
						set start [tell $fp]
					}
					seek $fp $start
					ns_set put $form $name $value
				}
			}
			close $fp
		}


		proc send_mail_dev {to from subject body {Bcc ""} {cc ""}} {
			package require mime 
			package require smtp
			set token [mime::initialize -canonical text/html  -string $body]
			mime::setheader $token Subject $subject
			mime::setheader $token From $from
			mime::setheader $token To $to
			if {$Bcc != ""} {  mime::setheader $token Bcc $Bcc -mode append }
			#Sometimes the mail won't be sent because the ORIGINATOR isn't set as a good e-mail address..
			#Next time if problems occur use the -debug 1 option
			set config [ns_cache_get lostmvc config.[getConfigName]] 

			smtp::sendmessage $token -ports [list 465 587] -recipients $to -servers smtp.gmail.com -username [dict get $config mailsettings username] -password [::base64::decode [dict get $config mailsettings password]]

			mime::finalize $token
		}



		proc send_mail_mandrill_smtp {to from subject body {Bcc ""} {cc ""}} {
			package require mime 
			package require smtp
			package require SASL ;#IF YYOU DON'T USE SASL IT WOn'T AUHENTICATE SUCCSESSFULLY!
			global host port smtp_user smtp_password 
			set token [mime::initialize -canonical text/html  -string $body]
			if {$Bcc != ""} {  mime::setheader $token Bcc $Bcc -mode append }
			#Sometimes the mail won't be sent because the ORIGINATOR isn't set as a good e-mail address..
			#Next time if problems occur use the -debug 1 option

			set config [ns_cache_get lostmvc config.[getConfigName]] 

			smtp::sendmessage $token -debug 0 -usetls 1 \
				-username [dict get $config mandrill username] -password [dict get $config mandrill password] \
				-ports [dict get $config mandrill port] -recipients $to -servers [dict get $config mandrill host] \
				-header [list From $from] \
				-header [list To $to] \
				-header [list Subject $subject] \
				-header [list Date "[clock format [clock seconds]]"]
			mime::finalize $token

			ns_log Notice "Sent e-mail from $from to $to"
		}

		#Sending mail through naviserver
		proc send_mail_naviserver {to from subject body {bcc ""} {cc ""}} {
		#	ns_sendmail $to info@unitedbrainpower.com $subject $body "" $bcc
			set extraheaders [ns_set create]
			ns_set put $extraheaders "MIME-Version" "1.0"
			ns_set put $extraheaders "Content-type" "text/html; charset=UTF-8"
			ns_set put $extraheaders X-Mailer "LostMVC Mailer 1.0"
			ns_sendmail $to $from $subject $body $extraheaders $bcc $cc
		}

		proc send_mail {args} {
			send_mail_naviserver {*}$args 
		}

		############################
		# Date and Time functions
		############################
   proc getTimestampDay {{unixtime ""}} {
	   if {$unixtime == ""} { set unixtime [clock seconds] }
	   return [clock format $unixtime -format "%Y-%m-%d"]
   }


   proc getTimestamp {{unixtime ""}} {
	   if {$unixtime == ""} { set unixtime [clock seconds] }
	   return [clock format $unixtime -format "%Y-%m-%d %H:%M:%S"]
   }

   proc getTimestampTz {{unixtime ""}} {
	   if {$unixtime == ""} { set unixtime [clock seconds] }
	   return [clock format $unixtime -format "%Y-%m-%d %H:%M:%S%z"]
   }

   proc beautifulDate {args} {
	   ns_parseargs {{-locale ""} {-hour 0} -- time} $args
	   if {$hour} {
		   set hour " at %H:%M"
	   } else { set hour "" }
	   if {$locale == ""} {
		   set locale [msgcat::mclocale]
	   }
	   if {$time != ""} {
		   set time [scanTz $time]
		   return [clock format $time -locale $locale -format "%A, %d %B %Y $hour"]
	   }
   }
   proc scanTz {time} {
	   if {![string is integer $time]} {
		   set r [string range $time 19 19]
		   if {$r != "" && ($r == "-" || $r == "+")} {
			   set time [clock scan $time -format {%Y-%m-%d %H:%M:%S%z} ]	
		   } else {
			   set time [clock scan $time]
		   }
	   }
	   return $time
   }
   proc howlongago {time} {
   # Returns the difference between $time and now in vague terms
	   set diff [expr {[clock seconds] - $time}]
	   # What units are we dealing with (don't care about leap years -
	   # we're being vague, after all :)
	   foreach {div unit} {
		   "60*60*24*365"        year
		   "60*60*24*30"         month
		   "60*60*24*7"          week
		   "60*60*24"            day
		   "60*60"               hour
		   "60"                  minute
		   "1"                   second
	   } {
		   if {[set num [expr $diff / ($div)]] > 0} {
			   break
		   }
	   } 

	   #TODO translation in multiple languages..
	   if {$num != 1} {
		   append unit "s" ;#or .pl 
	   }
	   set unit [mc $unit]
	   if {$num == 0} { return [mc "now"] }
	   if {$num == 1} { return [mc {a %1$s ago} $unit] }
	   if {$num == 2} { return [mc {a couple of %1$s ago} $unit] }
	   if {$num > 2 && $num < 5} { return [mc {a few %1$s ago} $unit] }
	   return [mc {%1$s %2$s ago} $num $unit]
   }
   #LREMOVE
   if {[info command lremove] == ""} {
	   proc lremove {args} {
		   if {[llength $args] < 2} {
			   puts stderr {Wrong # args: should be "lremove ?-all? list pattern"}
		   }
		   set list [lindex $args end-1]
		   set elements [lindex $args end]
		   if [string match -all [lindex $args 0]] {
			   foreach element $elements {
				   set list [lsearch -all -inline -not -exact $list $element]
			   }
		   } else {
		   # Using lreplace to truncate the list saves having to calculate
		   # ranges or offsets from the indexed element. The trimming is
		   # necessary in cases where the first or last element is the
		   # indexed element.
			   foreach element $elements {
				   set idx [lsearch $list $element]
				   set list [string trim \
					   "[lreplace $list $idx end] [lreplace $list 0 $idx]"]
			   }
		   }
		   return $list
	   }
   }
   ############################
   # Dictionary Pretty PRINT!
   ############################
   proc dict_format {dict} { 
	   dictformat_rec $dict "" "\t" 
   } 


   proc isdict {v} { 
	   string match "value is a dict *" [::tcl::unsupported::representation $v] 
   } 

   proc lasubdict {dictname key subkey value} {
	   upvar 1 $dictname dictvar
	   dict set dictvar $key $subkey "[if {[dict exists $dictvar $key $subkey]} { dict get $dictvar $key $subkey }] $value"
   }
   #Thanks to http://wiki.tcl.tk/17680
   proc dict'sort {dict args} {
	   set res {}
	   foreach key [lsort {*}$args [dict keys $dict]] {
		   dict set res $key [dict get $dict $key] 
	   }
	   set res
   }

   ## helper function - do the real work recursively 
   # use accumulator for indentation 
   proc dictformat_rec {dict indent indentstring} {
   # unpack this dimension 
	   dict for {key value} $dict { 
		   if {[isdict $value]} { 
		   #append result "$indent[list $key]\n$indent\{\n" 
			   append result "$indent[list $key] \{\n" 
			   append result "[dictformat_rec $value "$indentstring$indent" $indentstring]\n" 
			   append result "$indent\}\n" 
		   } else { 
			   append result "$indent[list $key] [list $value]\n" 
		   }
	   }

	   return $result 
   }

   #always place this at bottom because of VIM things.. put it as last function 
   #Generates a JSON from a TCL dictionary
   #Ripped from: http://rosettacode.org/wiki/JSON#Tcl
   proc tcl2json value {
   # Guess the type of the value; deep *UNSUPPORTED* magic!
	   regexp {^value is a (.*?) with a refcount} \
		   [::tcl::unsupported::representation $value] -> type

	   switch $type {
		   string {
		   # Skip to the mapping code at the bottom
		   }
		   dict {
			   set result "{"
			   set pfx ""
			   dict for {k v} $value {
				   append result $pfx [tcl2json $k] ": " [tcl2json $v]
				   set pfx ", "
			   }
			   return [append result "}"]
		   }
		   list {
			   set result "\["
			   set pfx ""
			   foreach v $value {
				   append result $pfx [tcl2json $v]
				   set pfx ", "
			   }
			   return [append result "\]"]
		   }
		   int - double {
			   return [expr {$value}]
		   }
		   booleanString {
			   return [expr {$value ? "true" : "false"}]
		   }
		   default {
		   # Some other type; do some guessing...
			   if {$value eq "null"} {
			   # Tcl has *no* null value at all; empty strings are semantically
			   # different and absent variables aren't values. So cheat!
				   return $value
			   } elseif {[string is integer -strict $value]} {
				   return [expr {$value}]
			   } elseif {[string is double -strict $value]} {
				   return [expr {$value}]
			   } elseif {[string is boolean -strict $value]} {
				   return [expr {$value ? "true" : "false"}]
			   }
		   }
	   }

	   # For simplicity, all "bad" characters are mapped to \u... substitutions
	   set mapped [subst -novariables [regsub -all {[][\u0000-\u001f\\""]} \
													 $value {[format "\\\\u%04x" [scan {& } %c]]}]]
												 return "\"$mapped\"" ;#"
	   }
	   namespace export *
   }
namespace import -force lostmvc::*
