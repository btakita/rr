require "#{File.dirname(__FILE__)}/spec_helper"

class TestUnitTestSuite
  def run
    require_tests

    puts "Running Test::Unit Test Suite"
  end

  def require_tests
    dir = File.dirname(__FILE__)
    Dir["#{dir}/rr/test_unit/**/*_test.rb"].each do |file|
      require File.expand_path(file)
    end
  end
end

if $0 == __FILE__
  TestUnitTestSuite.new.run
end
