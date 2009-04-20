# this one is easy
SCRIPT_LINES__ = {}
at_exit {
 puts "==== "
 
 backtrace_with_code = $!.backtrace.map{|bt| 
   file, line, junk = bt.split(":")
   line = line.to_i - 1 
   actual_file = SCRIPT_LINES__[file]
   actual_line = actual_file[line] if actual_file
   "#{bt}\n\t#{actual_line.strip if actual_line}"
 } 
   
 puts backtrace_with_code
 puts "===="
}
