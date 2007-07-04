dir = File.dirname(__FILE__)
require "#{dir}/../../environment_fixture_setup"
require "rr/adapters/test_unit"

require "test/unit"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end