require "rubygems"
require "spec"

class TestUnitExampleSuite
  def run
    options = ::Spec::Runner::OptionParser.new.parse(ARGV.dup, STDERR, STDOUT, false)
    $behaviour_runner = options.create_behaviour_runner

    require_specs

    puts "Running Test::Unit Example Suite"
    $behaviour_runner.run(ARGV, false)
  end

  def require_specs
    dir = File.dirname(__FILE__)
    Dir["#{dir}/rr/test_unit/**/*_example.rb"].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  TestUnitExampleSuite.new.run
end
