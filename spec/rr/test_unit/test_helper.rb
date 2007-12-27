dir = File.dirname(__FILE__)
require "spec/environment_fixture_setup"

require "test/unit"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end