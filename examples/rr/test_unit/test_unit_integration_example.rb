dir = File.dirname(__FILE__)
require "#{dir}/test_helper"

class FakeTestCase < Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def setup
    super
    @subject = Object.new
  end

  def teardown
    super
  end

  def test_using_a_mock
    mock()
  end
end
