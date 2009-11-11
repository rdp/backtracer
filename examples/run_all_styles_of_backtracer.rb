require 'faster_rubygems'
for file in Dir.glob("../lib/backtracer_*") do
 next if file =~ /_tracer/
 commands = []
 for crash_file in ['crash.rb'] do
  commands << "ruby -rfaster_rubygems -r#{file} #{crash_file}"
 end
  for command in commands
  puts "\n\n\nrunning #{command}\n"
  system(command)
 end
  
end
