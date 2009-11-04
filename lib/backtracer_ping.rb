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
 raise 'appears no caller for all threads or Thread#backtrace in your current system'
end

time = $ping_interval || 5 # seconds
Thread.new {
  loop {
    sleep time
    pp fella.call
  }
}
