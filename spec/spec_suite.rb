require "rubygems"
require "bundler"
require "session"

class ExampleSuite
  attr_reader :bash
  def initialize
    @bash = Session::Bash.new
  end

  def run
    run_core_examples
    run_rspec_examples
    run_test_unit_examples
    run_minitest_examples
  end

  def run_core_examples
    run_suite("#{dir}/core_spec_suite.rb #{spec_opts}") || raise("Core suite Failed")
  end

  def run_rspec_examples
    run_suite("#{dir}/rspec_spec_suite.rb #{spec_opts}") || raise("Rspec suite Failed")
  end

  def run_test_unit_examples
    run_suite("#{dir}/test_unit_spec_suite.rb") || raise("Test::Unit suite Failed")
  end

  def run_minitest_examples
    run_suite("#{dir}/minitest_spec_suite.rb") || raise("MiniTest suite Failed")
  end

  def run_suite(path)
    # From http://www.eglug.org/node/946
    bash.execute "exec 3>&1", :out => STDOUT, :err => STDERR
    bash.execute "ruby -W #{path} 2>&1 >&3 3>&- | grep -v 'warning: useless use of' 3>&-; STATUS=${PIPESTATUS[0]}", :out => STDOUT, :err => STDERR
    status = bash.execute("echo $STATUS")[0].to_s.strip.to_i
    bash.execute "exec 3>&-", :out => STDOUT, :err => STDERR
    return status == 0
  end

  def spec_opts
    File.read("#{dir}/spec.opts").split("\n").join(" ")
  end

  def dir
    File.dirname(__FILE__)
  end
end

if $0 == __FILE__
  ExampleSuite.new.run
end
