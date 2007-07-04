dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "examples/rr/space_helper"

require "rr/adapters/rspec"
Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end
