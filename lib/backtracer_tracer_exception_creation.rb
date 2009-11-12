require 'faster_rubygems'
require 'event_hook'

class Demo < EventHook
  def self.process(*args)

   # args => [64, #<RuntimeError: hello>, :initialize, Exception]
   begin
     if args[1].is_a? Exception
       puts args.inspect
     end
   rescue 
     # fantastically, this check fails within rails at times
   end
  end
end

Demo.start_hook

# TODO 1.9 compat
#set_trace_func proc {|*args| puts args.inspect }
