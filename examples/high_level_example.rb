dir = File.dirname(__FILE__)
require "#{dir}/example_helper"

# mock
# - probe
# - stub
describe "RR existing object inline interactions" do
  before(:each) do
    @obj = Object.new
  end

  after(:each) do
    RR::Space.instance.reset_doubles
  end

  it "mocks" do
    obj = @obj

    # TODO: BT - Remove this block when rspec support is added to RR.
    # We do this to avoid a conflict with Rspec's mock method.
    Object.new.instance_eval do
      mock(obj).to_s {"a value"}
    end
    @obj.to_s.should == "a value"
    proc {@obj.to_s}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "re-mocks" do
    obj = @obj
    Object.new.instance_eval do
      mock(obj).to_s {"a value"}
    end
    Object.new.instance_eval do
      mock(obj).to_s {"a value"}.twice
    end
    @obj.to_s.should == "a value"
    @obj.to_s.should == "a value"
    proc {@obj.to_s}.should raise_error(RR::Expectations::TimesCalledExpectationError)
  end

  it "probes" do
    expected_to_s_value = @obj.to_s
    probe(@obj).to_s
    @obj.to_s.should == expected_to_s_value
    proc {@obj.to_s}.should raise_error
  end

  it "re-probes" do
    expected_to_s_value = @obj.to_s
    probe(@obj).to_s

    probe(@obj).to_s.twice
    @obj.to_s.should == expected_to_s_value
    @obj.to_s.should == expected_to_s_value
    proc {@obj.to_s}.should raise_error
  end

  it "stubs" do
    obj = @obj
    Object.new.instance_eval do
      stub(obj).to_s {"a value"}
    end
    @obj.to_s.should == "a value"
  end

  it "re-stubs" do
    obj = @obj
    Object.new.instance_eval do
      stub(obj).to_s {"a value"}
    end

    Object.new.instance_eval do
      stub(obj).to_s {"a value"}
    end
    
    @obj.to_s.should == "a value"
  end
end

describe "RR existing object blocks interactions" do
  before(:each) do
    @obj = Object.new
  end

  after(:each) do
    RR::Space.instance.reset_doubles
  end

  it "mocks" do
    obj = @obj
    Object.new.instance_eval do
      mock obj do |c|
        c.to_s {"a value"}
        c.to_sym {:crazy}
      end
    end
    @obj.to_s.should == "a value"
    @obj.to_sym.should == :crazy
  end

  it "probes" do
    def @obj.foobar_1(*args)
      :original_value_1
    end

    def @obj.foobar_2
      :original_value_2
    end

    obj = @obj
    Object.new.instance_eval do
      probe obj do |c|
        c.foobar_1(1)
        c.foobar_2
      end
    end
    @obj.foobar_1(1).should == :original_value_1
    proc {@obj.foobar_1(:blah)}.should raise_error

    @obj.foobar_2.should == :original_value_2
    proc {@obj.foobar_2(:blah)}.should raise_error
  end

  it "stubs" do
    obj = @obj
    Object.new.instance_eval do
      stub obj do |d|
        d.to_s {"a value"}
        d.to_sym {:crazy}
      end
    end
    @obj.to_s.should == "a value"
    @obj.to_sym.should == :crazy
  end
end
