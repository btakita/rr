require "rubygems"
require "spec"

class RspecExampleSuite
  def run
    puts "Running Rspec Example Suite"
    dir = File.dirname(__FILE__)
    Dir["#{dir}/rr/rspec/**/*_spec.rb"].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  RspecExampleSuite.new.run
end
