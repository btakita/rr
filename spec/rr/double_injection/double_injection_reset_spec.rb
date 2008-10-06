require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection do
    macro("cleans up by removing the __rr__method") do
      it "cleans up by removing the __rr__method" do
        @double_injection.bind
        @subject.methods.should include("__rr__foobar")

        @double_injection.reset
        @subject.methods.should_not include("__rr__foobar")
      end
    end

    describe "#reset" do
      context "when method does not exist" do
        send("cleans up by removing the __rr__method")

        before do
          @subject = Object.new
          @method_name = :foobar
          @subject.methods.should_not include(@method_name.to_s)
          @double_injection = DoubleInjection.new(@subject, @method_name)
        end

        it "removes the method" do
          @double_injection.bind
          @subject.methods.should include(@method_name.to_s)

          @double_injection.reset
          @subject.methods.should_not include(@method_name.to_s)
          lambda {@subject.foobar}.should raise_error(NoMethodError)
        end
      end

      context "when method exists" do
        send("cleans up by removing the __rr__method")

        before do
          @subject = Object.new
          @method_name = :foobar
          def @subject.foobar
            :original_foobar
          end
          @subject.methods.should include(@method_name.to_s)
          @original_method = @subject.method(@method_name)
          @double_injection = DoubleInjection.new(@subject, @method_name)

          @double_injection.bind
          @subject.methods.should include(@method_name.to_s)
        end

        it "rebind original method" do
          @double_injection.reset
          @subject.methods.should include(@method_name.to_s)
          @subject.foobar.should == :original_foobar
        end
      end

      context "when method with block exists" do
        send("cleans up by removing the __rr__method")

        before do
          @subject = Object.new
          @method_name = :foobar
          def @subject.foobar
            yield(:original_argument)
          end
          @subject.methods.should include(@method_name.to_s)
          @original_method = @subject.method(@method_name)
          @double_injection = DoubleInjection.new(@subject, @method_name)

          @double_injection.bind
          @subject.methods.should include(@method_name.to_s)
        end

        it "rebinds original method with block" do
          @double_injection.reset
          @subject.methods.should include(@method_name.to_s)

          original_argument = nil
          @subject.foobar do |arg|
            original_argument = arg
          end
          original_argument.should == :original_argument
        end
      end
    end
  end
end
