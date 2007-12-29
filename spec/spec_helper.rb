dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "spec/rr/space/space_helper"
require "spec/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "spec/rr/adapters/definition_methods_spec_helper"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end
