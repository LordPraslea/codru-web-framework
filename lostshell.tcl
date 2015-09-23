#!/usr/bin/env tclsh
#//////////////////////////
#echo export PATH=\${PATH}:/home/user/Programare/Tcl/  >>  ~/.bashrc 
#chmod +x lostshell.tcl
#//////////////////////////
#:Author: Clinciu Andrei 
#:Email: <info@andreiclinciu.net>

# == List Shell

package require nx

if {0} {
	#read config file and write it with each change
	bookmarks {
		bookmark location
		bookmark2 location2
	}
	commands {
		name { what to run }
		name2 { what to run 2 }
	}
	
}

::nx::Slot method type=choice {name value arg} {
  if {$value ni [split $arg |]} {
    error "Value '$value' of parameter $name not in permissible values $arg"
  }
}

nx::Class create LostShell {
	
	:public  method main {argv argc} {
	
	#view if object method exists.. if not default, if yes run with functions..
	#TODO use foreach..?
		set firstWord [lindex $argv 0]
		set secondToLastWord [lrange $argv 1 end]
		if {[:info  lookup method $firstWord] != "" } {
			:$firstWord {*}$secondToLastWord 
		} else { puts "Sorry, the command $firstWord doesn't exist.. try using \"help\"" }
		
	}
	
	:public  method bookmark {args} {
		puts "bookmark-ing.. [pwd]"
	}
	
	:public  method go {args} {
		puts "Go-ing to bookmark $args"
		cd $args
	}
	
	:public  method deleteBookmark {args} {
		puts "Deleting bookmark $args"
	}
	
#.An Example Sidebar
#************************************************
#Any AsciiDoc SectionBody element (apart from
#SidebarBlocks) can be placed inside a sidebar.
#************************************************
	:public  method registerCommand {args} {
		puts "Registering command  $args"
	}
	
	:public  method runCommand {args} {
		puts "running command  $args"
		exec sudo   /opt/ns/bin/nsd -c -u www-data -t /opt/ns/conf/ubp-config.tcl > stdin
	}
	
# === makeDoc creating documentation
#

	:public  method makeDoc {{-tcl 1} file} {
		puts "Making documentation  $file [info script]"
		puts [array get env ]
		if {$tcl} {
			exec  >&@stdout source-doc-beautifier.tcl $file
			exec  >&@stdout asciidoc -f [file dir [info script]]/asciidoc.conf -b html5 -a tabsize=4 -a icons -a toc2 [regsub {\.tcl} $file .txt]
		} else {
			#don't forget to do apt-get install source-highlight
			exec  >&@stdout asciidoc -b html5 -a tabsize=4 -a icons -a toc2 [regsub {\.tcl} $file .txt]
		}
		
	#	exec asciidoc  [regsub {.tcl} $args .txt]
	}
	
	:public  method makePdf {{-tcl 1} file} {
		puts "Making documentation  $file [info script]"
		puts [array get env ]
		if {$tcl} {
			exec  >&@stdout source-doc-beautifier.tcl $file
			exec  >&@stdout a2x -fpdf -dbook --no-xmllint  --dblatex-opts "-P latex.output.revhistory=0" [regsub {\.tcl} $file .txt]
		} else {
			#don't forget to do apt-get install source-highlight
			exec  >&@stdout 	a2x -fpdf -dbook --no-xmllint  --dblatex-opts "-P latex.output.revhistory=0" [regsub {\.tcl} $file .txt]
		}
		
	}
	
	
	
	#TODO CPU watcher
	# If cpu is 100% for longer than 60 seconds for a certain PID, kill it
	# this means that the cpu is  100% at each interval
	#ps aux --sort -%cpu | head -10
	:public  method cpuWatcher {{-count:integer 10} {-interval:integer 5} {-maxCpu 100}  {-maxTime 60}  } {
		
	}
	
	:public  method startMemoryWatcher  {{-count:integer 10} {-interval:integer 5} {-maxMemory 1GB}   } {
			puts -nonewline "([:getTimestamp]): MemoryWatcher (by LostOne) is running"
			puts	" in the background checking processes higher than $maxMemory \n every $interval seconds"
			set :runs 0
			:memoryWatcher -count $count -interval $interval -maxMemory $maxMemory  
			vwait forever
	}
	
	#Memory watcher
	#TODO watch and kill only if it's in list watchProcesses
	#{watchProcesses:optional}
	:public  method memoryWatcher {{-count:integer 10} {-interval:integer 5} {-maxMemory 1GB}   } {
		#{USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND} 
		#RSS (real memory size or resident set size in 1024 byte units)
		set psData [exec ps  aux  --sort -rss | head -$count]
		set processesData [lrange  [split $psData \n] 1 end]
		set permittedMaxMemory [:toBytes $maxMemory]
		
		:showFreeMemoryAtIntervals
		
		foreach  process $processesData {
			set pid [lindex $process 1]
			set memory [expr {[lindex $process 5]*1024}]
			set command [lindex $process 10]
			if {[expr {$permittedMaxMemory*0.85}] < $memory} {
				puts "([:getTimestamp]): $command [:humanBytes $memory]  is nearing the 85% level of Max Memory allowed $maxMemory"
			}
						
			if {$permittedMaxMemory < $memory} {
				puts "([:getTimestamp]): KILLING PID $pid $command uses [:humanBytes $memory] memory and currently exceeds  the maximum memory ($maxMemory) "
				#TODO permit app 15 seconds to redress itself before killing
				exec kill -9 $pid
			}
		}
		after [expr {int($interval*1000)}] [list lostshell memoryWatcher -count $count \
		-interval $interval -maxMemory $maxMemory  ]
		#needed If using from commandline

	}
	
	:public  method showFreeMemoryAtIntervals {} {
		incr :runs
		if {[expr {${:runs}%10}] == 0} {
			set data [exec free -b]
			set data [split $data \n]
			lassign [lindex $data 2] a b used free 
			puts "([:getTimestamp]): Used memory: [:humanBytes $used] \t Free memory:  [:humanBytes $free]"
		}
	}
	
	#COnvertion to human readable number
	
	:public  method humanBytes {{-precision 1} number} {
		set byteList [list 1 kB 2 MB 3 GB 4 TB]
		set lastPower 0; set lastHumanReadable B
		foreach {power humanReadable} $byteList {
			if {![expr {int($number)/1024**$power}]} { 
				set human  [format %.${precision}f%s [expr {$number/1024.**$lastPower}] $lastHumanReadable]
				return $human
			}
			set lastPower $power
			set lastHumanReadable $humanReadable
		}
	}
	#Conversion from human readable to pc readable (bytes)
	:public  method toBytes {args} {
		set byteList [list 1 kB 2 MB 3 GB 4 TB]
		regexp {(\d+\.?\d*)\s*([a-zA-Z]{0,2})} $args ->  digits extension
		set listIndex [lsearch -nocase $byteList $extension]
		set power [lindex $byteList $listIndex-1]
		
		set bytes [expr {$digits*1024**$power}]
		return $bytes
	}
	
	:public  method  getTimestampTz {{unixtime ""}} {
			if {$unixtime == ""} { set unixtime [clock seconds] }
			return [clock format $unixtime -format "%Y-%m-%d %H:%M:%S%z"]
	}
	:public  method  getTimestamp {{unixtime ""}} {
			if {$unixtime == ""} { set unixtime [clock seconds] }
			return [clock format $unixtime -format "%Y-%m-%d %H:%M:%S"]
	}


	:public  method terminal:password:get {promptString} {

	# Turn off echoing, but leave newlines on.  That looks better.
	# Note that the terminal is left in cooked mode, so people can still use backspace
		exec stty -echo echonl <@stdin

		# Print the prompt
		puts  stdout $promptString
		flush stdout

		# Read that password!  :^)
		gets stdin password

		# Reset the terminal
		exec stty echo -echonl <@stdin

		return $password
	}
	
	:public method terminal:confirmPassword {promptString} {
		set password "pass" ; set confirmPassword "pass2"
		while {$password != $confirmPassword} {
			set password [:terminal:password:get $promptString ]
			set confirmPassword [:terminal:password:get "Confirm password"]
		}
		return $password
	}

	#DEFAULT is to return Y/N
	#If you change options to other letters/numbers remember to catch the output
	# Y/N are boolean values so you can treat them as such
	:method terminal:confirm:continue {{-default y} {-options {y "confirm" n "cancel" } } message} {
		set default [string toupper $default]

			if {[info exists :acceptAllDefault]} {
				if {${:acceptAllDefault}} {
					return $default
				}
			}

		set defaultmsg ""
			foreach {nr optionText} $options {
				append defaultmsg "\n\t${nr}. $optionText "
					if {$default == [string toupper $nr]} { append defaultmsg (default) }

			}

		set confirm [:terminal:confirm:outputMsg $message $defaultmsg]

			foreach {nr optionText} $options {
				if {$confirm == [string toupper $nr]} {
					return $confirm
				}
			}

		return $default
	}
	
	:method terminal:confirm:outputMsg {message defaultmsg} {
		foreground yellow
		puts -nonewline  stdout $message
		flush stdout

		foreground green
		puts -nonewline  stdout $defaultmsg 

		foreground white
		puts -nonewline  stdout "\nEnter your choice:  "
		flush stdout

		gets stdin confirm
		set confirm [string toupper $confirm]

		return $confirm
	}

	:method terminal:confirm {message} {
		foreground green
		puts -nonewline  stdout $defaultmsg 
		flush stdout
	
		gets stdin confirm

		return $confirm
	}


	:public  method commandlineprogress {{-total 50} {-char "#"} {-iteration 10} } {
		puts -nonewline stdout {[}
		for {set var 0} {$var < $total} {incr var} {
			puts -nonewline stdout $char
			flush stdout
			after $iteration
		}
		puts "\] \n Complete!"
	}

	:public  method getUserAndPassword {} {
		puts "Please enter your username"
		gets stdin username
		set password 	[:terminal:password:get "How about you give us your password?"]
		puts "Registering $username with pw $password"
	}

	


}
# Bash Color (Linux Only)	
# Utility interfaces to the low-level command
proc capability cap {expr {![catch {exec tput -S << $cap}]}}
proc colorterm {} {expr {[capability setaf] && [capability setab]}}
proc tput args {exec tput -S << $args >/dev/tty}
array set color {black 0 red 1 green 2 yellow 3 blue 4 magenta 5 cyan 6 white 7 }
proc foreground x {exec tput -S << "setaf $::color($x)" > /dev/tty}
proc background x {exec tput -S << "setab $::color($x)" > /dev/tty}
proc reset {} {exec tput sgr0 > /dev/tty}

array set bashcolor {
	bold \033\[1m
	dim \033\[2m
	underline \033\[4m
	blink \033\[5m
	inverted \033\[7m
	hidden \033\[8m
	reset \033\[0m
	
	black \033\[30m
	red \033\[31m
	green \033\[32m
	yellow \033\[33m
	blue \033\[34m
	magenta \033\[35m
	cyan \033\[36m
	lightgray \033\[37m
	darkgray \033\[90m
	lightred \033\[91m
	lightgreen \033\[92m
	lightyellow \033\[93m
	lightblue \033\[94m
	lightmagenta \033\[95m
	lightcyan \033\[96m
	white \033\[97m
}

if {[info exists argv0]} {
	if { [info script] eq $::argv0 } {
		LostShell create lostshell
		lostshell main $argv $argc
	} 
}


