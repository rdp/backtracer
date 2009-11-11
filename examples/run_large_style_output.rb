command = "ruby -v -r../lib/backtracer_locals.rb crash.rb"
puts 'running', command
system command
