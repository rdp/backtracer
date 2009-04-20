for file in Dir.glob("../backtrace_*") do
 for crash_file in ['../crash.rb', '../crash_longer.rb'] do
  puts 'running ' + file + ' against ' + crash_file
  system("ruby -r#{file} #{crash_file}")
 end
  
end
