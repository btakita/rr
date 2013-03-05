require File.expand_path('../../../global_helper', __FILE__)

require 'minitest/autorun'

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end
