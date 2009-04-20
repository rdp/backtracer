# this one is easy
SCRIPT_LINES__ = {}
at_exit {
 puts "==== "
 puts $!.backtrace.join("\n")
 puts "===="
}
