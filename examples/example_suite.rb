require "rubygems"
require "spec"

class ExampleSuite
  def run
    options = ::Spec::Runner::OptionParser.new.parse(ARGV.dup, STDERR, STDOUT, false)
    $behaviour_runner = options.create_behaviour_runner

    run_core_examples
    run_rspec_examples
    run_test_unit_examples
  end

  def run_core_examples
    system("ruby #{dir}/core_example_suite.rb") || raise("Core suite Failed")
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