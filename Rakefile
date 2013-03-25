require 'rubygems'
require 'rake'

require File.expand_path('../spec/runner', __FILE__)

task :default => :spec

desc "Runs all of the tests"
task :spec do
  ARGV.clear
  unless SuitesRunner.new.run
    raise "Spec Suite failed"
  end
end

namespace :spec do
  SuitesRunner::TEST_SUITES.each do |path, class_fragment, desc|
    desc "Runs all of the #{desc} tests"
    task path do
      ARGV.clear
      require File.expand_path("../spec/suites/#{path}/runner.rb", __FILE__)
      unless Object.const_get("#{class_fragment}SuiteRunner").new.run
        raise "#{desc} Suite failed"
      end
    end
  end
end

begin
  require 'bundler'
  require 'bundler/gem_tasks'
rescue LoadError
  puts "Bundler isn't installed. Run `gem install bundler` to get it."
end
