require File.expand_path("#{File.dirname(__FILE__)}/../../environment_fixture_setup")

require "minitest/autorun"

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end
