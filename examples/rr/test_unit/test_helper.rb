dir = File.dirname(__FILE__)
require "examples/environment_fixture_setup"
require "rr/adapters/test_unit"

require "test/unit"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end