require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
module Adapters
  describe RRMethods, "#any_times" do
    it_should_behave_like "RR::Adapters::RRMethods"
    
    it "returns an AnyTimesMatcher" do
      any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end

    it "rr_any_times returns an AnyTimesMatcher" do
      rr_any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end
  end
end
end
