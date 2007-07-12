require "examples/example_helper"

module RR
module Extensions
  describe DoubleMethods, "#mock" do
    before do
      extend RR::Extensions::DoubleMethods
      @subject = Object.new
    end

    it "sets up the RR mock call chain" do
      should_create_mock_call_chain mock(@subject)
    end

    it "sets up the RR mock call chain with rr_mock" do
      should_create_mock_call_chain rr_mock(@subject)
    end

    def should_create_mock_call_chain(creator)
      class << @subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.matcher.should == TimesCalledMatchers::IntegerMatcher.new(1)
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityError
      scenario.argument_expectation.expected_arguments.should == [1, 2]

      @subject.foobar(1, 2).should == :baz
    end
  end

  describe DoubleMethods, "#stub" do
    before do
      extend RR::Extensions::DoubleMethods
      @subject = Object.new
    end

    it "sets up the RR stub call chain" do
      should_create_stub_call_chain stub(@subject)
    end

    it "sets up the RR stub call chain with rr_stub" do
      should_create_stub_call_chain rr_stub(@subject)
    end

    def should_create_stub_call_chain(creator)
      class << @subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2) {:baz}
      scenario.times_called_expectation.should == nil
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityError
      @subject.foobar(1, 2).should == :baz
    end
  end

  describe DoubleMethods, "#probe" do
    before do
      extend RR::Extensions::DoubleMethods
      @subject = Object.new
    end

    it "sets up the RR probe call chain" do
      creator = probe(@subject)
    end

    it "sets up the RR probe call chain with rr_probe" do
      creator = rr_probe(@subject)
    end

    def should_create_probe_call_chain(creator)
      class << @subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2)
      scenario.times_called_expectation.times.should == 1
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityError
      scenario.argument_expectation.expected_arguments.should == [1, 2]

      @subject.foobar(1, 2).should == :original_value
    end
  end

  describe DoubleMethods, "#do_not_allow" do
    before do
      extend RR::Extensions::DoubleMethods
      @subject = Object.new
    end

    it "sets up the RR do_not_allow call chain" do
      should_create_do_not_allow_call_chain do_not_allow(@subject)
    end

    it "sets up the RR do_not_allow call chain with rr_do_not_allow" do
      should_create_do_not_allow_call_chain rr_do_not_allow(@subject)
    end

    it "sets up the RR do_not_allow call chain" do
      should_create_do_not_allow_call_chain dont_allow(@subject)
    end

    it "sets up the RR do_not_allow call chain with rr_do_not_allow" do
      should_create_do_not_allow_call_chain rr_dont_allow(@subject)
    end

    def should_create_do_not_allow_call_chain(creator)
      class << @subject
        def foobar(*args)
          :original_value
        end
      end

      scenario = creator.foobar(1, 2)
      scenario.times_called_expectation.matcher.should == TimesCalledMatchers::IntegerMatcher.new(0)
      scenario.argument_expectation.class.should == RR::Expectations::ArgumentEqualityError
      scenario.argument_expectation.expected_arguments.should == [1, 2]
    end
  end
end
end
