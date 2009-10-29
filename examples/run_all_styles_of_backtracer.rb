for file in Dir.glob("../lib/backtrace_*") do
 commands = []
 for crash_file in ['crash.rb'] do
  commands << "ruby -r#{file} #{crash_file}"
 end
 #commands << "ruby -v -r../backtrace_with_code_and_locals.rb ../crash.rb"
 for command in commands
  puts "\n\n\nrunning #{command}\n"
  system(command)
 end
  
end
