require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe Rspec do
      attr_reader :fixture, :method_name

      describe "#setup_mocks_for_rspec" do
        subject { Object.new }

        before do
          @fixture = Object.new
          fixture.extend Rspec
          @method_name = :foobar
        end

        it "resets the double_injections" do
          stub(subject).foobar
          ::RR::Injections::DoubleInjection.instances.should_not be_empty

          fixture.setup_mocks_for_rspec
          expect(::RR::Injections::DoubleInjection.instances).to be_empty
        end
      end

      describe "#verify_mocks_for_rspec" do
        subject { Object.new }

        before do
          @fixture = Object.new
          fixture.extend Rspec
          @method_name = :foobar
        end

        it "verifies the double_injections" do
          mock(subject).foobar

          expect {
            fixture.verify_mocks_for_rspec
          }.to raise_error(::RR::Errors::TimesCalledError)
          expect(::RR::Injections::DoubleInjection.instances).to be_empty
        end
      end

      describe "#teardown_mocks_for_rspec" do
        subject { Object.new }

        before do
          @fixture = Object.new
          fixture.extend Rspec
          @method_name = :foobar
        end

        it "resets the double_injections" do
          stub(subject).foobar
          ::RR::Injections::DoubleInjection.instances.should_not be_empty

          fixture.teardown_mocks_for_rspec
          expect(::RR::Injections::DoubleInjection.instances).to be_empty
        end
      end

      describe "#trim_backtrace" do
        it "does not set trim_backtrace" do
          expect(RR.trim_backtrace).to eq false
        end
      end

      describe "backtrace tweaking" do
        it "hides rr library from the backtrace by default" do
          file = File.expand_path('../../../rspec_backtrace_tweaking_spec_fixture.rb', __FILE__)
          output = `rspec -o /dev/null #{file}`
          output.should_not include("lib/rr")
        end
      end

      describe '#have_received' do
        it "creates an invocation matcher with a method name" do
          method  = :test
          matcher = 'fake'
          mock(RR::Adapters::Rspec::InvocationMatcher).new(method) { matcher }
          expect(have_received(method)).to eq matcher
        end

        it "creates an invocation matcher without a method name" do
          matcher = 'fake'
          mock(RR::Adapters::Rspec::InvocationMatcher).new(nil) { matcher }
          expect(have_received).to eq matcher
        end
      end
    end
  end
end
