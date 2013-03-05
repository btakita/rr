require File.expand_path('../test_helper', __FILE__)

class TestUnitSuiteRunner
  def run
    puts "Running Test::Unit example suite"
    Dir[File.expand_path("../{.,*,**}/*_test.rb", __FILE__)].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  TestUnitSuiteRunner.new.run
end
