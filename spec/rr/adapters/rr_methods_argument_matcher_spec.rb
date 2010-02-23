require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module Adapters
    describe RRMethods do
      describe "#anything" do
        it_should_behave_like "RR::Adapters::RRMethods"

        it "returns an Anything matcher" do
          anything.should == RR::WildcardMatchers::Anything.new
        end

        it "rr_anything returns an Anything matcher" do
          rr_anything.should == RR::WildcardMatchers::Anything.new
        end
      end

      describe "#is_a" do
        it_should_behave_like "RR::Adapters::RRMethods"

        it "returns an IsA matcher" do
          is_a(Integer).should == RR::WildcardMatchers::IsA.new(Integer)
        end

        it "rr_is_a returns an IsA matcher" do
          rr_is_a(Integer).should == RR::WildcardMatchers::IsA.new(Integer)
        end
      end

      describe "#numeric" do
        it_should_behave_like "RR::Adapters::RRMethods"

        it "returns an Numeric matcher" do
          numeric.should == RR::WildcardMatchers::Numeric.new
        end

        it "rr_numeric returns an Numeric matcher" do
          rr_numeric.should == RR::WildcardMatchers::Numeric.new
        end
      end

      describe "#boolean" do
        it_should_behave_like "RR::Adapters::RRMethods"

        it "returns an Boolean matcher" do
          boolean.should == RR::WildcardMatchers::Boolean.new
        end

        it "rr_boolean returns an Boolean matcher" do
          rr_boolean.should == RR::WildcardMatchers::Boolean.new
        end
      end

      describe "#duck_type" do
        it_should_behave_like "RR::Adapters::RRMethods"

        it "returns a DuckType matcher" do
          duck_type(:one, :two).should == RR::WildcardMatchers::DuckType.new(:one, :two)
        end

        it "rr_duck_type returns a DuckType matcher" do
          rr_duck_type(:one, :two).should == RR::WildcardMatchers::DuckType.new(:one, :two)
        end
      end
    end
  end
end
