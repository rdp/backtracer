require File.dirname(__FILE__) + '/backtracer' # everybody wants this, right?
require 'ruby-debug'
Debugger.start
puts 'hit ctrl + c to drop into a debugger'
trap "INT", "debugger"

if $0 == __FILE__
 sleep # test
end