require "#{File.dirname(__FILE__)}/spec_helper"

class CoreExampleSuite
  def run
    files = Dir["#{File.dirname(__FILE__)}/**/*_spec.rb"]
    files.delete_if {|file| file.include?('rspec/')}
    files.delete_if {|file| file.include?('test_unit/')}
    puts "Running Rspec Example Suite"
    files.each do |file|
      require File.expand_path(file)
#      puts "require '#{file}'"
    end
  end
end

if $0 == __FILE__
  CoreExampleSuite.new.run
end
