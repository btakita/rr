require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection do
    describe "#reset" do
      attr_reader :subject, :method_name, :double_injection
      context "when method does not exist" do
        before do
          @subject = Object.new
          @method_name = :foobar
          subject.methods.should_not include(method_name.to_s)
          @double_injection = DoubleInjection.new(subject, method_name, (class << subject; self; end))
        end

        it "removes the method" do
          double_injection.bind
          subject.methods.should include(method_name.to_s)

          double_injection.reset
          subject.methods.should_not include(method_name.to_s)
          lambda {subject.foobar}.should raise_error(NoMethodError)
        end
      end

      context "when method exists" do
        before do
          @subject = Object.new
          @method_name = :foobar
          def subject.foobar
            :original_foobar
          end
          subject.methods.should include(method_name.to_s)
          @original_method = subject.method(method_name)
          @double_injection = RR::Space.double_injection(subject, method_name)
          subject.methods.should include(method_name.to_s)
        end

        it "rebind original method" do
          double_injection.reset
          subject.methods.should include(method_name.to_s)
          subject.foobar.should == :original_foobar
        end
      end

      context "when method with block exists" do
        before do
          @subject = Object.new
          @method_name = :foobar
          def subject.foobar
            yield(:original_argument)
          end
          subject.methods.should include(method_name.to_s)
          @original_method = subject.method(method_name)
          @double_injection = RR::Space.double_injection(subject, method_name)

          subject.methods.should include(method_name.to_s)
        end

        it "rebinds original method with block" do
          double_injection.reset
          subject.methods.should include(method_name.to_s)

          original_argument = nil
          subject.foobar do |arg|
            original_argument = arg
          end
          original_argument.should == :original_argument
        end
      end
    end
  end
end
