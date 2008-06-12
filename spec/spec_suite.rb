class ExampleSuite
  def run
    run_core_examples
    run_rspec_examples
    run_test_unit_examples
  end

  def run_core_examples
    system("ruby #{dir}/core_spec_suite.rb --options #{dir}/spec.opts") || raise("Core suite Failed")
  end

  def run_rspec_examples
    system("ruby #{dir}/rspec_spec_suite.rb --options #{dir}/spec.opts") || raise("Rspec suite Failed")
  end

  def run_test_unit_examples
    system("ruby #{dir}/test_unit_spec_suite.rb") || raise("Test::Unit suite Failed")
  end

  def dir
    File.dirname(__FILE__)
  end
end

if $0 == __FILE__
  ExampleSuite.new.run
end