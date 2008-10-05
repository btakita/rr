require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

describe Range do
  attr_reader :matcher

  before do
    @matcher = 2..3
  end

  describe "#wildcard_match?" do
    context "when passed-in number falls within the Range" do
      it "returns true" do
        matcher.should be_wildcard_match(3)
      end
    end

    context "when passed-in number does not fall within the Range" do
      it "returns false" do
        matcher.should_not be_wildcard_match(7)
      end
    end

    context "when passed-in argument is not a number" do
      it "returns false" do
        matcher.should_not be_wildcard_match("Not a number")
      end
    end
  end  
  
  describe "#inspect" do
    it "returns the range" do
      matcher.inspect.should == "2..3"
    end
  end
end
