dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"
require "#{dir}/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "#{dir}/rr/adapters/rr_methods_spec_helper"

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

describe "Swapped Space", :shared => true do
  before do
    @original_space = RR::Space.instance
    RR::Space.instance = RR::Space.new
    @space = RR::Space.instance
  end

  after(:each) do
    RR::Space.instance = @original_space
  end
end

module Spec::Example::ExampleMethods
  def new_double(double_injection=double_injection, double_definition=RR::DoubleDefinitions::DoubleDefinition.new(creator = RR::DoubleDefinitions::DoubleDefinitionCreator.new, subject))
    RR::Double.new(
      double_injection,
      double_definition
    )
  end
end