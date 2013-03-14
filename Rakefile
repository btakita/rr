require 'rake'

require File.expand_path('../spec/runner.rb', __FILE__)

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
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "rr"
    s.summary = "RR (Double Ruby) is a double framework that features a rich " <<
                "selection of double techniques and a terse syntax. " <<
                "http://xunitpatterns.com/Test%20Double.html"
    s.email = "brian@pivotallabs.com"
    s.homepage = "http://pivotallabs.com"
    s.description = "RR (Double Ruby) is a double framework that features a rich " <<
                    "selection of double techniques and a terse syntax. " <<
                    "http://xunitpatterns.com/Test%20Double.html"
    s.authors = ["Brian Takita"]
    s.files = FileList[
      '[A-Z]*',
      '*.rb',
      'lib/**/*.rb',
      'spec/**/*.rb'
    ].to_a
    s.test_files = Dir.glob('spec/*_spec.rb')
    s.has_rdoc = true
    s.extra_rdoc_files = [ "README.rdoc", "CHANGES" ]
    s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
