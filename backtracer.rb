#
#   backtracer.rb - display backtrace of most recent error on exit [quality back trace, mind you]
# 	based off tracer.rb, unroller, python
#   	original tracer.rb by Keiju ISHITSUKA(Nippon Rational Inc.)
# Tons of the code is useless and could be removed, but at least it works

require 'rubygems'
require 'ruby-debug'
Debugger.start # we use this to track args.

#Debugger.keep_frame_binding = true # whatever this did :P
#
# tracer main class
#
class Tracer
  @RCS_ID='-$Id: tracer.rb,v 1.8 1998/05/19 03:42:49 keiju Exp keiju $-'

  @stdout = STDOUT
  @verbose = false
  class << self
    attr :verbose, true
    alias verbose? verbose
    attr :stdout, true
  end
  
  EVENT_SYMBOL = {
    "line" => "-",
    "call" => ">",
    "return" => "<",
    "class" => "C",
    "end" => "E",
    "c-call" => ">",
    "c-return" => "<",
    "raise" => "R"
  }
  
  def initialize
    @threads = Hash.new
    if defined? Thread.main
      @threads[Thread.main.object_id] = 0
    else
      @threads[Thread.current.object_id] = 0
    end

    @get_line_procs = {}

    @filters = []
  end
  
  def stdout
    Tracer.stdout
  end

  def on
    if block_given?
      on
      begin
	yield
      ensure
	off
      end
    else
      set_trace_func method(:trace_func).to_proc
      stdout.print "Trace on\n" if Tracer.verbose?
    end
  end
  
  def off
    set_trace_func nil
    stdout.print "Trace off\n" if Tracer.verbose?
  end

  def add_filter(p = proc)
    @filters.push p
  end

  def set_get_line_procs(file, p = proc)
    @get_line_procs[file] = p
  end

  def get_line(file, line)
   self.class.get_line(file, line)
  end

  def self.get_line(file, line)
    @get_line_procs ||= {}
    if p = @get_line_procs[file]
      return p.call(line)
    end

    unless list = SCRIPT_LINES__[file]
      begin
	f = open(file)
	begin 
	  SCRIPT_LINES__[file] = list = f.readlines
	ensure
	  f.close
	end
      rescue
	SCRIPT_LINES__[file] = list = []
      end
    end

    if l = list[line - 1]
      l
    else
      "-\n"
    end
  end
  
  def get_thread_no
    if no = @threads[Thread.current.object_id]
      no
    else
      @threads[Thread.current.object_id] = @threads.size
    end
  end

  require 'pp' 
  @@depths = {} # I think I added this [rdp]
  @@last_line = nil
  @@last_file = nil
  @@last_symbol = nil
  def trace_func(event, file, line, id, binding, klass, *nothing)
   begin
    return if file == __FILE__

    type = EVENT_SYMBOL[event] # "<" or ">"
    thread_no = get_thread_no
    Thread.current['backtrace'] ||= []
    @@depths[thread_no] ||= 0
    Thread.current['backtrace'] << nil if Thread.current['backtrace'].length  < (@@depths[thread_no] ) # pad it :)
    if type == ">"
      @@depths[thread_no] += 1
    elsif type == "<"
      @@depths[thread_no] -= 1
    end

    for p in @filters
      return unless p.call event, file, line, id, binding, klass
    end
    return if file.include? 'ruby-debug' # debugger output

    saved_crit = Thread.critical
    Thread.critical = true
# TODO only do the backtrace if last command was 'raise'
    if type == 'R'
         Thread.current['backtrace'][@@depths[thread_no] - 1] = [[file, line], [], binding]
         Thread.current['backtrace'] = Thread.current['backtrace'][0..@@depths[thread_no]] # clear old stuffs
    end

    if [file, line] != @@last_line # for output sake [not output too many lines]
      if @@last_symbol == '>' # then we need to add to the backtrace--we've advanced down a call in the callstack and can now glean its variables' values
         previous_frame_binding = Debugger.current_context.frame_binding(2)
	 collected = []
         args = Debugger.current_context.frame_args 1 rescue nil # maybe it had no arguments [ltodo check]

	 if args
	   for arg in args
		value =  eval(arg, previous_frame_binding)
		collected << [arg, value]
	   end 
	 else
	   print "WEIRD--please report err spot 1, how to reproduce"
         end
         print 'args were ', collected.inspect, "\n" if $VERBOSE

	 Thread.current['backtrace'][@@depths[thread_no] - 1] = [[@@last_file, @@last_line], collected, previous_frame_binding]
      end
    end

    out = " |" * @@depths[thread_no] + sprintf("#%d:%s:%d:%s:%s: %s",
       get_thread_no,
       file,
       line,
       klass || '',
       type,
       get_line(file, line))

   print out if $VERBOSE
   @@last_line =  line
   @@last_file = file
   @@last_symbol = type

   Thread.critical = saved_crit
   rescue Exception => e
	print "BAD" + e.to_s + e.backtrace.inspect
   end
  end

  Single = new
  def Tracer.on
    if block_given?
      Single.on{yield}
    else
      Single.on
    end
  end
  
  def Tracer.off
    Single.off
  end
  
  def Tracer.set_get_line_procs(file_name, p = proc)
    Single.set_get_line_procs(file_name, p)
  end

  
  def Tracer.add_filter(p = proc)
    Single.add_filter(p)
  end

  def Tracer.output_locals(previous_binding, prefix="\t\t")
    locals_name = Kernel.eval("local_variables", previous_binding)
    locals = {}
    for name in locals_name do
	locals[name] = Kernel.eval(name, previous_binding)
    end
    
    puts "#{prefix}locals: " + locals.inspect
  end


  at_exit do # at_exit seems to be run by the last running Thread. Or an exiting thread? Not sure for always.
    off
    raise_location = Thread.current['backtrace'].pop
    loc = raise_location[0]
    puts
    puts "unhandled exception: #{loc[0]}:#{loc[1]}:  #{get_line loc[0], loc[1]}"
    output_locals(raise_location[2], "\t")
    puts "\t  from:\n"

    # last most one is redundant with the raise one...
    Thread.current['backtrace'].pop

    for loc, params, binding in Thread.current['backtrace'].reverse do
        original_line = get_line loc[0], loc[1]
	# TODO handle non parentheses
	line_no_params = original_line.split('(')[0]
	line_no_params.gsub!('def ', '')
	line_params = line_no_params + "("
	comma = ""
	for param in params do
	 line_params += param[0].to_s + "=>" + param[1].to_s + ", "
	 comma = ", "
	end
	line_params = line_params[0..-3] # strip off ending comma
	line_params += ")" if line_params =~ /\(/
        puts "\t#{loc[0]}:#{loc[1]} #{line_params}" 
	output_locals binding
    end


    exit!
  end
end

SCRIPT_LINES__ = {} unless defined? SCRIPT_LINES__
Tracer::on
if $0 == __FILE__
  # direct call
    
  $0 = ARGV[0]
  ARGV.shift
  Tracer.on
  require $0
elsif caller(0).size == 1
  Tracer.on
end

# TODO: do are arg snapshots capture it right [soon enough]?
# TODO: don't output error if none thrown :)
