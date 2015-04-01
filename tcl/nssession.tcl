
# Hillbilly version of ns_session
#TODO protection from "hack attempt" by checking IP
#TODO testing to see if it's not better to use dict than array 
catch {
	#Cache size of 1 megabyte
	ns_cache_create sessions [expr {1024*1024}] ;
#	ns_cache_create conns 1024
}

proc ns_session { command {args ""}} {
	set db dbipg1
	# Expire sessions after 15-30 minutes of inactivity
	#
	set expires 1800
	#Keep session 24 hours..
	set longlogin 180000
	# update expiration after each get.
	set touch 1
	# Persist sessions to disk
	set persist 1

	switch $command {

		exists {
			# Check for existence of session.  Sessions are 
			# said to exist if there is an entry in the cache
			# that has not expired with the given id.  They are
			# created by the create, put, or get commands.
			if {[llength $args] == 0} {
				set sid [ns_session id]
			} else {
				set sid [lindex $args 0]
			}
			if {[llength [ns_cache_keys sessions $sid]]} {
				return 1
			} else {
				return 0
			}
		}

		list {
			# List all existing sessions
			return [ns_cache_keys sessions]
		}	
		new {

			upvar #0 session_id session_id
			set session_id [ns_sha1 [ns_conn peeraddr][ns_rand 100000]]
			ns_setcookie -path / session_id $session_id
			return $session_id
		}	
		id {
			# Get or set session id and return it
			# This needs to return the same id if called multiple times
			# by one conn.  TODO
			upvar #0 session_id session_id
			if {[info exists session_id]} {
				return $session_id
			}
#TODO implement different cookie names based on domain/project..?
#OR just put a different key in session for each project
#OR a different cookie name..
#
#different cookie name : CON'S.. the app needs to save this..somewhere:)
#domain based.. PRO will work on a domain automatically CON if you want to allow multiple different logins.. etc won't work
#key in session PRO flexibilty CON every app needs to store it's name.. appname.userid when getting an userid..
			#		set key [lindex $args 0]
#			set value [lindex $args 1]
			set session_id [ns_getcookie session_id 0]
			if {$session_id == 0} {
				set session_id [ns_sha1 [ns_conn peeraddr][ns_rand 100000]]
				ns_setcookie -path / session_id $session_id
			}
			return $session_id
		}
		
		load {
			# Load session.  Also creates a session since it is called
			# from put and get.

			upvar sessiondata sessiondata
			if {[llength $args] > 0} {
				set session_id [lindex $args 0] 
			} else {
				set session_id [ns_session id]
			}

			set expires_at $expires
			if {[info exists sessiondata(longlogin)]} {
				set expires_at $longlogin
			}
			array set sessiondata \
				[ns_cache_eval -expires $expires_at -- sessions $session_id {
					list session.id $session_id session.start [ns_time] session.state clean session.server unused
				}]
			return 1
		}

		save {
			# Save the session to the cache
			# Optional session_id for use in recovering sessions on startup
			if {[llength $args] == 0} {
				set session_id [ns_session id]
			} else {
				set session_id [lindex $args 0]
				set persist 0
			}
			set expires_at $expires
			if {[llength $args] > 2} {
				set expires_at [lindex $args 1]
			}
			upvar sessiondata sessiondata
			if {[info exists sessiondata(longlogin)]} {
				set expires_at $longlogin
			}
			ns_cache_eval -expires $expires_at -force -- sessions $session_id {
				array get sessiondata
			}	
			if {$persist} {
				ns_session persist
			}
			return 1
		}

		delete {
				# Delete a given key
			ns_session load
			set key [lindex $args 0]
			array unset sessiondata $key
			ns_session save
			return 1		

		}

		destroy {
			# Delete a given key
			ns_session load

			set session_id [ns_session id]
			set key [lindex $args 0]
			array unset sessiondata
			if {[file exists [ns_pagepath]/sessions/$session_id.s]} {
			#	puts "Deleting key $session_id"
				catch { file delete [ns_pagepath]/sessions/$session_id.s }
			}
			ns_cache_flush sessions $session_id 
			ns_deletecookie session_id
			ns_session new
			ns_session save
			return 1
		}
		
		persist {
			# Save the sesssion to the database
			upvar sessiondata sessiondata
			set session_id [ns_session id]

			ns_session load
			set sessionserial [array get sessiondata]

			set sf [open [ns_pagepath]/sessions/$session_id.s w+]
			puts $sf $sessionserial
			close $sf
			#TODO SQL SAVE!

			#TODO SQL + DiskCache
			#Insert or update
		if {0} {	set result [dbi_dml -db $db {
				UPDATE session SET sessiondata=:sessionserial WHERE sessionid=:session_id;
				INSERT INTO session (sessionid, sessiondata)
					SELECT 2, :session, 'Z'
						WHERE NOT EXISTS (SELECT 1 FROM session WHERE id=3);
				INSERT INTO session (sessionid,sessiondata) VALUES (:session_id,:sessionserial)
				ON DUPLICATE KEY UPDATE sessiondata=:sessionserial} ] 
		}
			return 1
		}

		recover {
			# Read all session info from database into cache
			# run on startup.
			#
			puts "Recovering all sessions ..."
			
			foreach server [glob -type d [ns_server serverdir]/* ] {
				append server /www/sessions

				if {[file tail $server]=="lostmvc"} {  continue }
				puts "Loading sessions for server $server"
				#			foreach s [glob -no [ns_pagepath]/sessions/*.s]
				foreach s [glob -no $server/*.s] {
					set session_id [file tail [file rootname $s]]
					if {[ns_session exists $session_id]} {  continue }
					set sf [open $s r]
					set sessionserial [read $sf]
					close $sf

					array set sessiondata $sessionserial
					#Delete if NOT requested to store more than 48 hours
					#and if 1800 seconds have passed
					#	puts "Recovering #$session_id $sessiondata(session.start)"
					if {[info exists sessiondata(longlogin)]} {
						if {[expr {$sessiondata(session.start) + $longlogin}] < [ns_time]} {
							catch { file delete $s }
							continue
						}
						set expires_at [expr {[ns_time]-$sessiondata(session.start)+$longlogin}]
					} else { 
						if {[expr {$sessiondata(session.start) + $expires}] < [ns_time]} {
						#		puts " expired session $session_id [expr {$sessiondata(session.start)+$expires}] < [ns_time]"
							catch { file delete $s }
							continue
						}

						set expires_at [expr {[ns_time]-$sessiondata(session.start)+$expires}]
					}
					ns_session save $session_id $expires_at
					array unset sessiondata
				#	puts "Loaded $session_id with $sessionserial"
				}
			}
		#TODO SQL + DiskCache
		if {0} {
			foreach {sessionid sessiondataserial} [dbi_rows -db $db \
		{SELECT sessionid, sessiondata
				  FROM session
WHERE lastupdate > current_timestamp - '30 minutes'::interval}] {
		array set sessiondata $sessiondataserial
		ns_session save $sessionid
		array unset sessiondata
	}
	}
		}

		get {
			# Get a value from the current session and return it
			set default ""
			set key [lindex $args 0]	
			if {[llength $args] == 2} {
				set default [lindex $args 1]
			}
			ns_session load
			ns_session touch
			if {[info exists sessiondata($key)]} {
				return $sessiondata($key)
			} else {
				return $default
			}
		}

		put {
			# Set a session variable to a given value
			set key [lindex $args 0]
			set value [lindex $args 1]
			ns_session load
			set sessiondata($key) $value
			ns_session save
		}

		contains {
			# Tell if the current session has a given key in it
			set key [lindex $args 0]
			ns_session load
			if {[info exists sessiondata($key)]} {
				return 1
			} else {
				return 0
			}
		}

		touch {
			# update the expiration by saving the session data
			# Not using "force" means this should never do anything
			# other than update the expiration.

			upvar sessiondata sessiondata

			set expires_at $expires
			if {[info exists sessiondata(longlogin)]} {
				set expires_at $longlogin
			}
			if {$touch} {
				ns_cache_eval -force -expires $expires_at -- sessions [ns_session id]  {
					array get sessiondata
				}
			}
		}
	}
}	
#Only "Recover" sessions once every 10 minutes..
ns_cache_eval -expires 600 -- sessions lostmvc.session {

	ns_session recover
}

ns_register_proc GET /showsessions showsessions
proc showsessions {} {

	set html "your session id is [ns_session id]<br>"
	ns_session load
	append html "[array get sessiondata]"
	append html "<br><br>Other sessions: "
	foreach key [ns_cache_stats -contents sessions] {
		foreach {size expiry} $key {
			append html "<BR>Size: $size Expires: [ns_fmttime [ns_time seconds $expiry]]"
		}
	}
	ns_return 200 text/html $html
}
