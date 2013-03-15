require "#{File.dirname(__FILE__)}/spec_helper"

class RspecExampleSuite
  def run
    puts "Running Rspec Example Suite"
    dir = File.dirname(__FILE__)
    Dir["#{dir}/rr/rspec/**/*_spec.rb"].each do |file|
#      puts "require '#{file}'"
      require File.expand_path(file)
    end
  end
end

if $0 == __FILE__
  RspecExampleSuite.new.run
end
