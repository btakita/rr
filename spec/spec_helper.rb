dir = File.dirname(__FILE__)

require "#{dir}/environment_fixture_setup"

module ExampleMethods
  def eigen(object)
    class << object; self; end
  end
end

module ExampleGroupMethods
  def macro(name, &implementation)
    (class << self; self; end).class_eval do
      define_method(name, &implementation)
    end
  end
end

RSpec.configure do |c|
  c.include ExampleMethods
  c.extend ExampleGroupMethods
  c.mock_with :rr
end

Dir["#{dir}/shared/*.rb"].each {|fn| require fn }
