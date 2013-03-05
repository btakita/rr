require File.expand_path('../../../global_helper', __FILE__)

require "test/unit"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
