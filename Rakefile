require "rake"
require 'rake/contrib/rubyforgepublisher'
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'

desc "Runs the Rspec suite"
task(:default) do
  run_suite
end

desc "Runs the Rspec suite"
task(:spec) do
  run_suite
end

def run_suite
  dir = File.dirname(__FILE__)
  system("ruby #{dir}/spec/spec_suite.rb") || raise("Spec Suite failed")
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
    s.rubyforge_project = "pivotalrb"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
