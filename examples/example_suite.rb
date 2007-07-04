require "rubygems"
require "spec"

class ExampleSuite
  def run
    options = ::Spec::Runner::OptionParser.new.parse(ARGV.dup, STDERR, STDOUT, false)
    $behaviour_runner = options.create_behaviour_runner
    
    require_specs

    puts "Running Example Suite"
    $behaviour_runner.run(ARGV, false)

    run_rspec_examples
    run_test_unit_examples
  end

  def require_specs
    exclusions = []
    exclusions << "rspec/"
    exclusions << "test_unit/"

    Dir["#{dir}/**/*_example.rb"].each do |file|
      require file unless exclusions.any? {|match| file.include?(match)}
    end
  end

  def run_rspec_examples
    system("ruby #{dir}/rspec_example_suite.rb") || raise("Rspec suite Failed")
  end

  def run_test_unit_examples
    system("ruby #{dir}/test_unit_example_suite.rb") || raise("Test::Unit suite Failed")
  end

  def dir
    File.dirname(__FILE__)
  end
end

if $0 == __FILE__
  ExampleSuite.new.run
end
