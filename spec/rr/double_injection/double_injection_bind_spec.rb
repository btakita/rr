require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleInjection do
      describe "#bind" do
        context "with an existing method" do
          before do
            @subject = Object.new
            @method_name = :foobar
            def @subject.foobar;
              :original_foobar;
            end
            @original_method = @subject.method(@method_name)
            @subject.methods.should include(@method_name.to_s)
            @double_injection = DoubleInjection.new(@subject, @method_name)
          end

          it "overrides the original method with the double_injection's dispatching methods" do
            @subject.respond_to?(:__rr__foobar).should == false
            @double_injection.bind
            @subject.respond_to?(:__rr__foobar).should == true

            rr_foobar_called = false
            (class << @subject; self; end).class_eval do
              define_method :__rr__foobar do
                rr_foobar_called = true
              end
            end

            rr_foobar_called.should == false
            @subject.foobar
            rr_foobar_called.should == true
          end

          it "stores original method in __rr__original_method_name" do
            @double_injection.bind
            @subject.respond_to?(:__rr__original_foobar).should == true
            @subject.method(:__rr__original_foobar).should == @original_method
          end
        end

        context "without an existing method" do
          before do
            @subject = Object.new
            @method_name = :foobar
            @subject.methods.should_not include(@method_name.to_s)
            @double_injection = DoubleInjection.new(@subject, @method_name)
          end

          it "creates a new method with the double_injection's dispatching methods" do
            @subject.respond_to?(:__rr__foobar).should == false
            @double_injection.bind
            @subject.respond_to?(:__rr__foobar).should == true

            rr_foobar_called = false
            (class << @subject; self; end).class_eval do
              define_method :__rr__foobar do
                rr_foobar_called = true
              end
            end

            rr_foobar_called.should == false
            @subject.foobar
            rr_foobar_called.should == true
          end

          it "does not create method __rr__original_method_name" do
            @double_injection.bind
            @subject.respond_to?(:__rr__original_foobar).should == false
          end
        end

        context "with #==" do
          before do
            @subject = Object.new
            @method_name = :'=='
            @subject.should respond_to(@method_name)
            @original_method = @subject.method(@method_name)
            @subject.methods.should include(@method_name.to_s)
            @double_injection = DoubleInjection.new(@subject, @method_name)
          end

          it "overrides the original method with the double_injection's dispatching methods" do
            @subject.respond_to?(:"__rr__#{@method_name}").should == false
            @double_injection.bind
            @subject.respond_to?(:"__rr__#{@method_name}").should == true

            override_called = false
            method_name = @method_name
            (class << @subject; self; end).class_eval do
              define_method :"__rr__#{method_name}" do
                override_called = true
              end
            end

            override_called.should == false
            @subject == 1
            override_called.should == true
          end

          it "stores original method in __rr__original_method_name" do
            @double_injection.bind
            @subject.respond_to?(:"__rr__original_#{@method_name}").should == true
            @subject.method(:"__rr__original_#{@method_name}").should == @original_method
          end
        end        
      end
    end
  end
end