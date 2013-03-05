require File.expand_path('../spec_helper', __FILE__)

class RSpecSuiteRunner
  def run
    puts "Running RSpec example suite"
    Dir[File.expand_path("../{.,*,**}/*_spec.rb", __FILE__)].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  RSpecSuiteRunner.new.run
end
