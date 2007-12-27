dir = File.dirname(__FILE__)
require "#{dir}/test_helper"

class TestUnitIntegrationTest < Test::Unit::TestCase
  def setup
    super
    @subject = Object.new
  end

  def teardown
    super
  end

  def test_using_a_mock
    mock(@subject).foobar(1, 2) {:baz}
    assert_equal :baz, @subject.foobar(1, 2)
  end
  
  def test_using_a_stub
    stub(@subject).foobar {:baz}
    assert_equal :baz, @subject.foobar("any", "thing")
  end

  def test_using_a_mock_probe
    def @subject.foobar
      :baz
    end

    mock.probe(@subject).foobar
    assert_equal :baz, @subject.foobar
  end

  def test_using_a_stub_probe
    def @subject.foobar
      :baz
    end

    stub.probe(@subject).foobar
    assert_equal :baz, @subject.foobar
  end

  def test_times_called_verification
    mock(@subject).foobar(1, 2) {:baz}
    assert_raise RR::Errors::TimesCalledError do
      teardown
    end
  end
end
