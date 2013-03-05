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
    s.rubyforge_project = "pivotalrb"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
RUBYFORGE_PACKAGE_NAME = "rr (Double Ruby)"
# The package was renamed from "rr (Double R)" to "rr (Double Ruby)".
# When this was last run, the script did not work for the new name but it did work for the old name.
# Perhaps more time was needed for the name change to propagate?
#RUBYFORGE_PACKAGE_NAME = "rr (Double R)"

# This is hacked to get around the 3 character limitation for package names on Rubyforge.
# http://rubyforge.org/tracker/index.php?func=detail&aid=27026&group_id=5&atid=102
class Jeweler
  module Commands
    class ReleaseToRubyforge
      def run
        raise NoRubyForgeProjectInGemspecError unless @gemspec.rubyforge_project

        @rubyforge.configure rescue nil

        output.puts 'Logging in rubyforge'
        @rubyforge.login

        @rubyforge.userconfig['release_notes'] = @gemspec.description if @gemspec.description
        @rubyforge.userconfig['preformatted'] = true

        output.puts "Releasing #{@gemspec.name}-#{@version} to #{@gemspec.rubyforge_project}"
        begin
          @rubyforge.add_release(@gemspec.rubyforge_project, RUBYFORGE_PACKAGE_NAME, @version.to_s, @gemspec_helper.gem_path)
        rescue StandardError => e
          case e.message
          when /no <group_id> configured for <#{Regexp.escape @gemspec.rubyforge_project}>/
            raise RubyForgeProjectNotConfiguredError, @gemspec.rubyforge_project
          when /no <package_id> configured for <#{Regexp.escape @gemspec.name}>/i
            raise MissingRubyForgePackageError, @gemspec.name
          else
            raise
          end
        end
      end
    end
  end
end

