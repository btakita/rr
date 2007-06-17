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

      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.times.should == 1
      scenario.argument_expectation.should_match_arguments?.should == true
      scenario.argument_expectation.expected_arguments.should == [1, 2]
      
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
      
      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.should == nil
      scenario.argument_expectation.should_match_arguments?.should == false
      scenario.argument_expectation.expected_arguments.should == nil
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

      scenario = creator.foobar(1, 2)
      scenario.times_called_expectation.times.should == 1
      scenario.argument_expectation.should_match_arguments?.should == true
      scenario.argument_expectation.expected_arguments.should == [1, 2]
      
      subject.foobar(1, 2).should == :original_value
    end
  end
end
