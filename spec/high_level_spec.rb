dir = File.dirname(__FILE__)
require "#{dir}/spec_helper"

class HighLevelSpec
end

describe "RR" do
  before(:each) do
    @obj = Object.new
    extend RR::Adapters::RRMethods
  end

  after(:each) do
    RR.reset
  end

  describe "RR mock:" do
    it "mocks via inline call" do
      mock(@obj).to_s {"a value"}
      @obj.to_s.should == "a value"
      proc {@obj.to_s}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "allows ordering" do
      mock(@obj).to_s {"value 1"}.ordered
      mock(@obj).to_s {"value 2"}.twice.ordered
      @obj.to_s.should == "value 1"
      @obj.to_s.should == "value 2"
      @obj.to_s.should == "value 2"
      proc {@obj.to_s}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "mocks via block" do
      mock @obj do |c|
        c.to_s {"a value"}
        c.to_sym {:crazy}
      end
      @obj.to_s.should == "a value"
      @obj.to_sym.should == :crazy
    end

    it "has wildcard matchers" do
      mock(@obj).foobar(
        is_a(String),
        anything,
        numeric,
        boolean,
        duck_type(:to_s),
        /abc/
      ) {"value 1"}.twice
      @obj.foobar(
        'hello',
        Object.new,
        99,
        false,
        "My String",
        "Tabcola"
      ).should == "value 1"
      proc do
        @obj.foobar(:failure)
      end.should raise_error( RR::Errors::DoubleNotFoundError )
    end

    it "mocks methods without letters" do
      mock(@obj) == 55

      @obj == 55
      proc do
        @obj == 99
      end.should raise_error(RR::Errors::DoubleNotFoundError)
    end
  end

  describe "RR proxy:" do
    it "proxies via inline call" do
      expected_to_s_value = @obj.to_s
      mock.proxy(@obj).to_s
      @obj.to_s.should == expected_to_s_value
      proc {@obj.to_s}.should raise_error
    end

    it "proxy allows ordering" do
      def @obj.to_s(arg)
        "Original to_s with arg #{arg}"
      end
      mock.proxy(@obj).to_s(:foo).ordered
      mock.proxy(@obj).to_s(:bar).twice.ordered

      @obj.to_s(:foo).should == "Original to_s with arg foo"
      @obj.to_s(:bar).should == "Original to_s with arg bar"
      @obj.to_s(:bar).should == "Original to_s with arg bar"
      proc {@obj.to_s(:bar)}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "proxy allows ordering" do
      def @obj.to_s(arg)
        "Original to_s with arg #{arg}"
      end
      mock.proxy(@obj).to_s(:foo).ordered
      mock.proxy(@obj).to_s(:bar).twice.ordered

      @obj.to_s(:foo).should == "Original to_s with arg foo"
      @obj.to_s(:bar).should == "Original to_s with arg bar"
      @obj.to_s(:bar).should == "Original to_s with arg bar"
      proc {@obj.to_s(:bar)}.should raise_error(RR::Errors::TimesCalledError)
    end

    it "proxies via block" do
      def @obj.foobar_1(*args)
        :original_value_1
      end

      def @obj.foobar_2
        :original_value_2
      end

      mock.proxy @obj do |c|
        c.foobar_1(1)
        c.foobar_2
      end
      @obj.foobar_1(1).should == :original_value_1
      proc {@obj.foobar_1(:blah)}.should raise_error

      @obj.foobar_2.should == :original_value_2
      proc {@obj.foobar_2(:blah)}.should raise_error
    end

    it "proxies via block" do
      def @obj.foobar_1(*args)
        :original_value_1
      end

      def @obj.foobar_2
        :original_value_2
      end

      mock.proxy @obj do |c|
        c.foobar_1(1)
        c.foobar_2
      end
      @obj.foobar_1(1).should == :original_value_1
      proc {@obj.foobar_1(:blah)}.should raise_error

      @obj.foobar_2.should == :original_value_2
      proc {@obj.foobar_2(:blah)}.should raise_error
    end
  end

  describe "RR stub:" do
    it "stubs via inline call" do
      stub(@obj).to_s {"a value"}
      @obj.to_s.should == "a value"
    end

    it "allows ordering" do
      stub(@obj).to_s {"value 1"}.once.ordered
      stub(@obj).to_s {"value 2"}.once.ordered

      @obj.to_s.should == "value 1"
      @obj.to_s.should == "value 2"
    end

    it "stubs via block" do
      stub @obj do |d|
        d.to_s {"a value"}
        d.to_sym {:crazy}
      end
      @obj.to_s.should == "a value"
      @obj.to_sym.should == :crazy
    end

    it "stubs instance_of" do
      stub.instance_of(HighLevelSpec) do |o|
        o.to_s {"High Level Spec"}
      end
      HighLevelSpec.new.to_s.should == "High Level Spec"
    end

    it "stubs methods without letters" do
      stub(@obj).__send__(:==) {:equality}
      (@obj == 55).should == :equality
    end
  end
end
