require "rubygems"
require "spec"

class CoreExampleSuite
  def run
    options = ::Spec::Runner::OptionParser.new.parse(ARGV.dup, STDERR, STDOUT, false)
    options.configure
    $behaviour_runner = options.create_behaviour_runner

    require_specs

    puts "Running Rspec Example Suite"
    $behaviour_runner.run(ARGV, false)
  end

  def require_specs
    exclusions = []
    exclusions << "rspec/"
    exclusions << "test_unit/"

    Dir["#{File.dirname(__FILE__)}/**/*_example.rb"].each do |file|
      unless exclusions.any? {|match| file.include?(match)}
        require file
      end
    end
  end
end

if $0 == __FILE__
  CoreExampleSuite.new.run
end
