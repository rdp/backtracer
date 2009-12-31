# this one display full BT with code, at the end [no performance loss]

require 'rbconfig'
DOZE = Config::CONFIG['host_os'] =~ /mswin|mingw/

require File.dirname(__FILE__) + "/shared"

at_exit {
  if $! && !$!.is_a?(SystemExit) # SystemExit's are normal, not exceptional
    print "\n"
    print "\t" unless defined?($same_line)
    
    puts $!.inspect + ' ' + $!.to_s

    max = 0
    $!.backtrace.each{|bt_line| max = [bt_line.length, max].max}

    backtrace_with_code = $!.backtrace.map{ |bt_line|
      next if bt_line.include? 'bin/backtracer' # lines from ourself...
      if DOZE && bt_line[1..1] == ':'
        
        drive, file, line, junk = bt_line.split(":")
	#["C", "/dev/ruby/allgems/lib/allgems/GemWorker.rb", "91", "in `unpack'"]              
        file = drive + ":" + file
      else
        file, line, junk = bt_line.split(":")
      end
      line = line.to_i
      actual_code = Tracer.get_line(file, line)
      output_line = ''
      output_line += "%-#{max + 1}s " % bt_line unless $no_code_line_numbers
      if actual_code && actual_code != '-'
        output_line += "\n\t" unless defined?($same_line)
        output_line += actual_code.strip
      end
      output_line
    }

    previous_line = nil
    count = 0

    backtrace_with_code = backtrace_with_code.map{|line|
        if previous_line == nil
          # startup
          previous_line = line
          line
        elsif previous_line == line
          # redundant line
          count += 1
        
          nil
        else
          # good line
          previous_line = line
          if count > 0
            # first good line after a string of bad
            a = ["                 (repeat #{count} times) ", line]
            count = 0          
            a
           else
            line
          end
        end
    }.flatten.compact


    puts backtrace_with_code
    puts # blank line
    # for some reason this can be nil...
    $!.set_backtrace [] if $! # avoid the original backtrace being outputted--though annoyingly it does still output its #to_s...
    
  else
    puts "(backtracer: no exception found to backtrace)" if $DEBUG
  end
  # exit! TODO I guess do this once ours isn't *so* ugly
  # I'm not sure it's safe to do that, in case there are other at_exit's [?]
  # TODO compare with that fella xray
}
