require "rubygems"
require "spec"
dir = File.dirname(__FILE__)
$LOAD_PATH << "#{dir}/../lib"
require "rr"
require "ruby-debug"
require "pp"
require "examples/rr/space_helper"

require "rr/adapters/rspec"
Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

