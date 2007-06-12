dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe Kernel, "#mock" do
  it "sets up the RR mock call chain" do
    Object.new.instance_eval do
      creator = mock
      class << creator
        attr_reader :subject
      end
      subject = creator.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      proxy = creator.foobar(1, 2) {:baz}
      double = proxy.double
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
      creator = stub
      class << creator
        attr_reader :subject
      end
      subject = creator.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end
      
      proxy = creator.foobar(1, 2) {:baz}
      double = proxy.double
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
      creator = probe
      class << creator
        attr_reader :subject
      end
      subject = creator.subject
      subject.class.should == Object

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      proxy = creator.foobar(1, 2)
      double = proxy.double
      double.expectations[RR::Expectations::TimesCalledExpectation].times.should == 1
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].should_match_arguments?.should == true
      double.expectations[RR::Expectations::ArgumentEqualityExpectation].expected_arguments.should == [1, 2]
      subject.foobar(1, 2).should == :original_value
    end
  end
end
