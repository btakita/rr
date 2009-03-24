require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestUnitBacktraceTest < Test::Unit::TestCase
  def setup
    super
    @subject = Object.new
  end

  def teardown
    super
  end

  def test_trim_backtrace_is_set
    assert RR.trim_backtrace
  end

  def test_backtrace_tweaking
    skip "Skipped, because there is no Test::Unit::TestResult in this Test::Unit. Don't worry, this is totally fine." unless defined?(Test::Unit::TestResult)
    old_result = @_result
    result = Test::Unit::TestResult.new

    error_display = nil
    result.add_listener(Test::Unit::TestResult::FAULT) do |f|
      error_display = f.long_display
    end
    test_case = self.class.new(:backtrace_tweaking)
    test_case.run(result) {}

    assert !error_display.include?("lib/rr")
  end

  def backtrace_tweaking
    mock(@subject).foobar
    RR::Space::instance.verify_double(@subject, :foobar)
  end
end
