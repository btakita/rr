require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection do
    attr_reader :subject, :method_name, :double_injection
    macro("sets up object and method_name") do
      it "sets up object and method_name" do
        double_injection.subject.should === subject
        double_injection.method_name.should == method_name.to_sym
      end
    end

    describe "#initialize" do
      context "when method_name is a symbol" do
        send("sets up object and method_name")

        before do
          @subject = Object.new
          @method_name = :foobar
          subject.methods.should_not include(method_name.to_s)
          @double_injection = DoubleInjection.new(subject, method_name)
        end
      end

      context "when method_name is a string" do
        send("sets up object and method_name")

        before do
          @subject = Object.new
          @method_name = 'foobar'
          subject.methods.should_not include(method_name)
          @double_injection = DoubleInjection.new(subject, method_name)
        end
      end

      context "when method does not exist on object" do
        send("sets up object and method_name")

        before do
          @subject = Object.new
          @method_name = :foobar
          subject.methods.should_not include(method_name.to_s)
          @double_injection = DoubleInjection.new(subject, method_name)
        end

        it "object does not have original method" do
          double_injection.object_has_original_method?.should be_false
        end
      end

      context "when method exists on object" do
        send("sets up object and method_name")

        before do
          @subject = Object.new
          @method_name = :to_s
          subject.methods.should include(method_name.to_s)
          @double_injection = DoubleInjection.new(subject, method_name)
        end

        it "has a original_method" do
          double_injection.object_has_original_method?.should be_true
        end
      end

      context "when method_name is ==" do
        send("sets up object and method_name")

        before do
          @subject = Object.new
          @method_name = '=='
          @double_injection = DoubleInjection.new(subject, method_name)
        end
      end
    end
  end
end
