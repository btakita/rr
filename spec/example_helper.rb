dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "spec/rr/space/space_helper"
require "spec/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "spec/rr/extensions/instance_methods_example_helper"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end
