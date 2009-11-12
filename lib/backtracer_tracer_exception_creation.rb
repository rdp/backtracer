require 'faster_rubygems'
require 'event_hook'

class Demo < EventHook
  def self.process(*args)

   # args => [64, #<RuntimeError: hello>, :initialize, Exception]
   if args[1].is_a? Exception
     puts args.inspect
   end
  end
end

Demo.start_hook

#set_trace_func proc {|*args| puts args.inspect }
raise 'hello'