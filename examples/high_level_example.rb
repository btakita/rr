dir = File.dirname(__FILE__)
require "#{dir}/example_helper"

# mock
# - probe
# - stub
describe "RR existing object inline interactions" do
  before(:each) do
    @obj = Object.new
  end

  it "mocks" #do
#    expect(@obj).to_s {"a value"}
#    @obj.to_s.should == "a value"
#    proc {@obj.to_s}.should raise_error
#
#    expect(@obj).to_s {"a value"}.twice
#    @obj.to_s.should == "a value"
#    @obj.to_s.should == "a value"
#    proc {@obj.to_s}.should raise_error
#  end

  it "probes" #do
#    expect(@obj).to_s
#    @obj.to_s.should == "foobar"
#    proc {@obj.to_s}.should raise_error
#
#    expect(@obj).to_s.twice
#    @obj.to_s.should == "foobar"
#    @obj.to_s.should == "foobar"
#    proc {@obj.to_s}.should raise_error
#  end

  it "stubs" #do
#    expect(@obj).to_s {"a value"}
#    @obj.to_s.should == "a value"
#  end
end

describe "RR existing object blocks interactions" do
  before(:each) do
    @obj = :foobar
  end

  it "mocks" #do
#    expect @obj do
#      to_s {"a value"}
#      to_sym {:crazy}
#    end
#    @obj.to_s.should == "a value"
#    @obj.to_sym.should == :crazy
#  end

  it "probes" #do
#    expect @obj do
#      to_s
#      to_sym
#    end
#    @obj.to_s.should == "foobar"
#    @obj.to_sym.should == :foobar
#  end

  it "stubs" #do
#    expect @obj do
#      to_s {"a value"}
#      to_sym {:crazy}
#    end
#    @obj.to_s.should == "a value"
#    @obj.to_sym.should == :crazy
#  end
end
