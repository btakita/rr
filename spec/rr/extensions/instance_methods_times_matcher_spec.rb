require "spec/spec_helper"

module RR
module Extensions
  describe InstanceMethods, "#any_times" do
    it_should_behave_like "RR::Extensions::InstanceMethods"
    
    it "returns an AnyTimesMatcher" do
      any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end

    it "rr_any_times returns an AnyTimesMatcher" do
      rr_any_times.should == TimesCalledMatchers::AnyTimesMatcher.new
    end
  end
end
end
