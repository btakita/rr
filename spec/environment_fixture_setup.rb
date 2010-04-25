require "rubygems"
require "spec"
require "spec/autorun"
require "bundler"
Bundler.setup

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require "rr"
require "pp"
