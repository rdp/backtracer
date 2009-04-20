# this one is easy
at_exit {
 puts "===="
 puts $!.backtrace.join("\n")
 puts "===="
}
