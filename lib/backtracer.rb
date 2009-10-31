# this one display full BT with code, at the end [no performance loss]
SCRIPT_LINES__ = {}
at_exit {
 puts "==== "
 if $!
  backtrace_with_code = $!.backtrace.map{|bt| 
   file, line, junk = bt.split(":")
   line = line.to_i - 1 
   actual_file = SCRIPT_LINES__[file]
   actual_line = actual_file[line] if actual_file
   "#{bt}\n\t#{actual_line.strip if actual_line}"
  } 
  puts backtrace_with_code
  puts "===="
 else
  puts "(no exception to backtrace)"
 end
   

}
