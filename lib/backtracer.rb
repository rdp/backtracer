# this one display full BT with code, at the end [no performance loss]

require File.dirname(__FILE__) + "/shared"
require 'sane'

at_exit {

  if $!
    puts "==== "
    bt2 = $!.backtrace
    backtrace_with_code = $!.backtrace.map{ |bt_line|
      if OS.windows? && bt_line[1..1] == ':'
        #["C", "/dev/ruby/allgems/lib/allgems/GemWorker.rb", "91", "in `unpack'"]      
        drive, file, line, junk = bt_line.split(":")
        file = drive + ":" + file
      else
        file, line, junk = bt_line.split(":")
      end
      line = line.to_i
#      line -= 1 unless line == 0 # not sure if needed
      actual_line = Tracer.get_line(file, line)
      "#{bt_line}\n\t#{actual_line.strip if actual_line}"
    }
    puts backtrace_with_code
    puts "===="
  else
    puts "(no exception found to backtrace)"
  end
  exit!
}
