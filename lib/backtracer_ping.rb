require 'pp'
gem 'sane', '0.9.1'
require 'sane/os'

def xray
 require 'xray'
 proc { Process.kill "QUIT", Process.pid; '' }
end

if Thread.current.respond_to? :backtrace
  fella = proc { 
    out = {}
    Thread.list.each{|t|
      out[t] = t.backtrace
    }
    out    
  }
elsif respond_to? :caller_for_all_threads
  if OS.windows?
    fella = proc {
      caller_for_all_threads
    }
  else
    fella = xray
  end
else
 # weak sauce for the old school users :)
 if OS.windows?

   trap("ILL") { puts "All threads:" + Thread.list.inspect, "Current thread:" + Thread.current.to_s, caller } # puts current thread caller
   fella = proc {  Process.kill "ILL", Process.pid } # send myself a signal
 else
   fella = xray
 end

end

time = $ping_interval || 5 # seconds
time = 1 if $0 == __FILE__
Thread.new {
  loop {
    sleep time
    pp 'current stack trace', Time.now, fella.call
  }
}

require File.dirname(__FILE__) + '/backtracer' # we want the normal backtracer, too

if $0 == __FILE__ # i.e. a test
 sleep
end