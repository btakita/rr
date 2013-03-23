class MinitestSuiteRunner
  def initialize
    @minitest_available = false
    unless RUBY_VERSION =~ /^1.8/
      require File.expand_path('../test_helper', __FILE__)
      @minitest_available = true
    end
  end

  def run
    if @minitest_available
      puts "Running MiniTest example suite"
      Dir[File.expand_path("../{.,*,**}/*_test.rb", __FILE__)].each do |file|
        require file
      end
    else
      puts "Skipping MiniTest suite since we're on Ruby 1.8"
    end
  end
end

if $0 == __FILE__
  MinitestSuiteRunner.new.run
end
