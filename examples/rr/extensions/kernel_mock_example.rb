dir = File.dirname(__FILE__)
require "#{dir}/../../example_helper"

describe Kernel, "#mock" do
  it "sets up the RR mock call chain" do
    Object.new.instance_eval do
      subject = Object.new
      creator = mock(subject)

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.times.should == 1
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
      scenario.argument_expectation.expected_arguments.should == [1, 2]
      
      subject.foobar(1, 2).should == :baz
    end
  end
end

describe Kernel, "#stub" do
  it "sets up the RR stub call chain" do
    Object.new.instance_eval do
      subject = Object.new
      creator = stub(subject)

      class << subject
        def foobar(*args)
          :original_value
        end
      end
      
      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.should == nil
      scenario.argument_expectation.class.should == RR::Expectations::AnyArgumentExpectation
      subject.foobar(1, 2).should == :baz
    end
  end
end

describe Kernel, "#probe" do
  it "sets up the RR probe call chain" do
    Object.new.instance_eval do
      subject = Object.new
      creator = probe(subject)

      class << subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2)
      scenario.times_called_expectation.times.should == 1
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityExpectation
      scenario.argument_expectation.expected_arguments.should == [1, 2]
      
      subject.foobar(1, 2).should == :original_value
    end
  end
end
