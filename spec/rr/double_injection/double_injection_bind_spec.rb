require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleInjection do
      attr_reader :subject, :method_name, :double_injection, :original_method
      describe "#bind" do
        context "with an existing method" do
          before do
            @subject = Object.new
            @method_name = :foobar
            def subject.foobar;
              :original_foobar;
            end
            @original_method = @subject.method(method_name)
            @subject.methods.should include(method_name.to_s)

            subject.method(:foobar).should == original_method
          end

          context "when the existing method is public" do
            before do
              stub(subject, method_name).returns {:new_foobar}
            end

            it "returns the value of the Double Injection" do
              subject.foobar.should == :new_foobar
            end

            it "overrides the original method with the double_injection's dispatching methods" do
              subject.method(:foobar).should_not == original_method
            end

            it "stores original method in __rr__original_method_alias_name" do
              subject.respond_to?(:__rr__original_foobar).should == true
              subject.method(:__rr__original_foobar).should == original_method
            end
          end

          context "when the existing method is private" do
            before do
              class << subject
                private :foobar
              end
              @double_injection = RR::Space.double_injection(subject, method_name)
            end

            it "overrides the original method with the double_injection's dispatching methods" do
              double_injection.bind
              subject.method(:foobar).should_not == original_method
            end

            it "stores original method in __rr__original_method_alias_name" do
              subject.private_methods.should include('__rr__original_foobar')
              subject.method(:__rr__original_foobar).should == original_method
            end
          end
        end

        context "without an existing method" do
          before do
            @subject = Object.new
            @method_name = :foobar
            subject.methods.should_not include(method_name.to_s)
            RR::Space.double_injection(subject, method_name)
          end

          it "creates a new method with the double_injection's dispatching methods" do
            subject.method(method_name).should_not be_nil
          end

          it "does not create method __rr__original_method_alias_name" do
            subject.respond_to?(:__rr__original_foobar).should == false
          end
        end

        context "with #==" do
          before do
            @subject = Object.new
            @method_name = :'=='
            subject.should respond_to(method_name)
            @original_method = subject.method(method_name)
            subject.methods.should include(method_name.to_s)
            @double_injection = RR::Space.double_injection(subject, method_name)
          end

          it "overrides the original method with the double_injection's dispatching methods" do
            subject.method(method_name).should_not == original_method
          end

          it "stores original method in __rr__original_method_alias_name" do
            subject.respond_to?(:"__rr__original_#{method_name}").should == true
            subject.method(:"__rr__original_#{method_name}").should == original_method
          end
        end        
      end
    end
  end
end