require File.expand_path('../test_helper', __FILE__)

class MinitestSuiteRunner
  def run
    puts "Running MiniTest example suite"
    Dir[File.expand_path("../{.,*,**}/*_test.rb", __FILE__)].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  MinitestSuiteRunner.new.run
end
