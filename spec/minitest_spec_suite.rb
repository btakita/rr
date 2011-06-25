require "rubygems"
require "spec"

class MiniTestTestSuite
  def run
    require_tests

    puts "Running MiniTest Test Suite"
  end

  def require_tests
    dir = File.dirname(__FILE__)
    Dir["#{dir}/rr/minitest/**/*_test.rb"].each do |file|
      require File.expand_path(file)
    end
  end
end

if $0 == __FILE__
  MiniTestTestSuite.new.run
end
