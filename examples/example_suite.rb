require "rubygems"
require "spec"

class ExampleSuite
  def run
    options = ::Spec::Runner::OptionParser.new.parse(ARGV.dup, STDERR, STDOUT, false)
    $behaviour_runner = options.create_behaviour_runner
    
    require_specs

    puts "Running Example Suite"
    $behaviour_runner.run(ARGV, false)

    run_rspec_specs
  end

  def require_specs
    exclusions = []
    exclusions << "rspec/"

    Dir["#{dir}/**/*_example.rb"].each do |file|
      require file unless exclusions.any? {|match| file.include?(match)}
    end
  end

  def run_rspec_specs
    system("ruby #{dir}/rspec_example_suite.rb") || raise("Rspec suite Failed")
  end

  def dir
    File.dirname(__FILE__)
  end
end

if $0 == __FILE__
  ExampleSuite.new.run
end
