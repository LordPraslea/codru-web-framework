#
# all.tcl --
#
#       This file contains a top-level script to run all of the tests.
#       Execute it by invoking "source all.tcl" when running nsd in
#       command mode in this directory.
#

package require Tcl 8.6
package require tcltest 2.2
namespace import tcltest::*
eval configure $argv -singleproc true -testdir [file dirname [info script]]


puts "FOLDER [file dirname [info script]]
"

rename tcltest::test tcltest::__test

proc tcltest::test args {

    ns_log dev >->-> \
        [format "%-16s" "[lindex $args 0]:"] ([string trim [lindex $args 1]])

    uplevel 1 tcltest::__test $args
}

ns_logctl severity DriverDebug true

runAllTests

#
# Shutdown the server to let the cleanup handlers run
#
#foreach s [ns_info servers] {puts stderr "$s: [ns_server -server $s stats]"}
ns_shutdown

#
# Wait until these are finished, ns_shutdown will terminate this script
#
after 2000 return
