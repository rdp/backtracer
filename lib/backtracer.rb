# this one display full BT with code, at the end [no performance loss]
require 'rbconfig'
WINDOZE = Config::CONFIG['host_os'] =~ /mswin|mingw/

require File.dirname(__FILE__) + "/shared"

at_exit {
  if $! && !$!.is_a?(SystemExit) # SystemExit's are normal, not exceptional
    puts "\n     " + $!.inspect + ' ' + $!.to_s
    bt2 = $!.backtrace
    backtrace_with_code = $!.backtrace.map{ |bt_line|
      if WINDOZE && bt_line[1..1] == ':'
        
        drive, file, line, junk = bt_line.split(":")
	#["C", "/dev/ruby/allgems/lib/allgems/GemWorker.rb", "91", "in `unpack'"]              
        file = drive + ":" + file
      else
        file, line, junk = bt_line.split(":")
      end
      line = line.to_i
      actual_line = Tracer.get_line(file, line)
      "#{bt_line}\n\t#{actual_line.strip if actual_line}"
    }
    puts backtrace_with_code
    puts
  else
    puts "(backtracer: no exception found to backtrace)" if $VERBOSE
  end
  # exit! TODO I guess do this once ours isn't *so* ugly
  # TODO compare with that fella xray
}
