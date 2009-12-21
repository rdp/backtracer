# this one is easy
at_exit {
 if $!
   puts "==== "
   puts $!.backtrace.join("\n")
   puts "===="
 else
   puts "(no exception detected)" if $DEBUG
 end
}
