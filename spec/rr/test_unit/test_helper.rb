require File.expand_path("#{File.dirname(__FILE__)}/../../environment_fixture_setup")

require "test/unit"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end