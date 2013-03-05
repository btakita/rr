require 'session'

class SuitesRunner
  TEST_SUITES = [
    [:rspec, 'RSpec', 'RSpec'],
    [:test_unit, 'TestUnit', 'Test::Unit'],
    [:minitest, 'Minitest', 'MiniTest']
  ]

  attr_reader :bash

  def initialize
    @bash = Session::Bash.new
  end

  def run
    TEST_SUITES.each do |path, class_fragment, desc|
      run_examples(path, class_fragment, desc)
    end
  end

  def run_examples(path, class_fragment, desc)
    path = File.expand_path("../suites/#{path}/runner.rb", __FILE__)
    # From http://www.eglug.org/node/946
    bash.execute "exec 3>&1", :out => STDOUT, :err => STDERR
    # XXX: why are we checking for this warning here...
    bash.execute "ruby -W #{path} 2>&1 >&3 3>&- | grep -v 'warning: useless use of' 3>&-; STATUS=${PIPESTATUS[0]}", :out => STDOUT, :err => STDERR
    status = bash.execute("echo $STATUS")[0].to_s.strip.to_i
    bash.execute "exec 3>&-", :out => STDOUT, :err => STDERR
    unless status == 0
      raise "#{desc} Suite Failed"
    end
  end
end

if $0 == __FILE__
  SuitesRunner.new.run
end

