dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe Kernel, "#mock" do
  it "sets up the RR mock call chain" do
    Object.new.instance_eval do
      proxy = mock
      class << proxy
        attr_reader :subject
      end
      subject = proxy.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      double = proxy.foobar(1, 2) {:baz}
      double.expectations[RR::Expectations::TimesCalledExpectation].times.should == 1
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].should_match_arguments?.should == true
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].expected_arguments.should == [1, 2]
      subject.foobar(1, 2).should == :baz
    end
  end
end

describe Kernel, "#stub" do
  it "sets up the RR stub call chain" do
    Object.new.instance_eval do
      proxy = stub
      class << proxy
        attr_reader :subject
      end
      subject = proxy.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end
      
      double = proxy.foobar(1, 2) {:baz}
      double.expectations[RR::Expectations::TimesCalledExpectation].should == nil
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].should_match_arguments?.should == false
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].expected_arguments.should == nil
      subject.foobar(1, 2).should == :baz
    end
  end
end

describe Kernel, "#probe" do
  it "sets up the RR probe call chain" do
    Object.new.instance_eval do
      proxy = probe
      class << proxy
        attr_reader :subject
      end
      subject = proxy.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      double = proxy.foobar(1, 2)
      double.expectations[RR::Expectations::TimesCalledExpectation].times.should == 1
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].should_match_arguments?.should == true
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].expected_arguments.should == [1, 2]
      subject.foobar(1, 2).should == :original_value
    end
  end
end
