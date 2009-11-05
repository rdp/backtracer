require 'pp'

if Thread.current.respond_to? :backtrace
  fella = proc { 
    out = {}
    Thread.list.each{|t|
      out[t] = t.backtrace
    }
    out    
  }
elsif respond_to? :caller_for_all_threads
  fella = proc {
    caller_for_all_threads
  }
else
 # weak sauce for the old school users :)
 trap("ILL") { puts "All threads:" + Thread.list.inspect, "Current thread:" + Thread.current.to_s, caller } # puts current thread caller
 fella = proc {  Process.kill "ILL", Process.pid } # send myself a signal
end

time = $ping_interval || 5 # seconds
time = 1 if $0 == __FILE__
Thread.new {
  loop {
    sleep time
    pp fella.call
  }
}

if $0 == __FILE__ # a test
 sleep
end