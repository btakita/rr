dir = File.dirname(__FILE__)
require "#{dir}/environment_fixture_setup"

shared_examples_for "Swapped Space" do
  attr_reader :space, :original_space
  before do
    @original_space = RR::Space.instance
    RR::Space.instance = RR::Space.new
    @space = RR::Space.instance
  end

  after(:each) do
    RR::Space.instance = @original_space
  end
end

class Rspec::ExampleGroup
  extend(Module.new do
    def macro(name, &implementation)
      (class << self; self; end).class_eval do
        define_method(name, &implementation)
      end
    end
  end)

  def eigen(object)
    class << object; self; end
  end
end

require "#{dir}/rr/expectations/times_called_expectation/times_called_expectation_helper"
require "#{dir}/rr/adapters/rr_methods_spec_helper"
ARGV.push("--format", "nested") unless ARGV.include?("--format")
ARGV.push("-b")

Rspec.configure do |config|
  config.mock_with :rr
end
