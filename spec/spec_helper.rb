dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "#{dir}/rr/space/space_helper"
require "#{dir}/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "#{dir}/rr/adapters/rr_methods_spec_helper"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end
