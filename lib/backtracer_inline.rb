# this one display full BT with code, at the end [no performance loss]
require 'rbconfig'
WINDOZE = Config::CONFIG['host_os'] =~ /mswin|mingw/
$same_line = true

require File.dirname(__FILE__) + "/shared"
require File.dirname(__FILE__) + "/backtracer.rb"
