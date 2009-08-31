require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  describe DoubleInjection do
    attr_reader :subject, :method_name, :double_injection
    macro("sets up subject and method_name") do
      it "sets up subject and method_name" do
        double_injection.subject.should === subject
        double_injection.method_name.should == method_name.to_sym
      end
    end

    describe "mock/stub" do
      context "when the subject responds to the injected method" do
        before do
          @subject = Object.new
          class << subject
            attr_reader :original_foobar_called
            
            def foobar
              @original_foobar_called = true
              :original_foobar
            end
          end
          def subject.foobar
            :original_foobar
          end
          subject.should respond_to(:foobar)
          subject.methods.should include('foobar')
          stub(subject).foobar {:new_foobar}
        end

        describe "being bound" do
          it "sets __rr__original_{method_name} to the original method" do
            subject.__rr__original_foobar.should == :original_foobar
          end

          describe "being called" do
            it "returns the return value of the block" do
              subject.foobar.should == :new_foobar
            end

            it "does not call the original method" do
              subject.foobar
              subject.original_foobar_called.should be_nil
            end
          end

          describe "being reset" do
            before do
              RR::Space.reset_double(subject, :foobar)
            end

            it "rebinds the original method" do
              subject.foobar.should == :original_foobar
            end

            it "removes __rr__original_{method_name}" do
              subject.should_not respond_to(:__rr__original_foobar)
            end
          end
        end
      end

      context "when the subject does not respond to the injected method" do
        before do
          @subject = Object.new
          subject.should_not respond_to(:foobar)
          subject.methods.should_not include('foobar')
          stub(subject).foobar {:new_foobar}
        end

        it "does not set __rr__original_{method_name} to the original method" do
          subject.should_not respond_to(:__rr__original_foobar)
        end

        describe "being called" do
          it "calls the newly defined method" do
            subject.foobar.should == :new_foobar
          end
        end

        describe "being reset" do
          before do
            RR::Space.reset_double(subject, :foobar)
          end

          it "unsets the foobar method" do
            subject.should_not respond_to(:foobar)
            subject.methods.should_not include('foobar')
          end
        end
      end
    end

    describe "mock/stub + proxy" do
      context "when the subject responds to the injected method" do
        context "when the subject has the method defined" do
          describe "being bound" do
            before do
              @subject = Object.new
              def subject.foobar
                :original_foobar
              end
              subject.should respond_to(:foobar)
              subject.methods.should include('foobar')
              stub.proxy(subject).foobar {:new_foobar}
            end

            it "aliases the original method to __rr__original_{method_name}" do
              subject.__rr__original_foobar.should == :original_foobar
            end

            it "replaces the original method with the new method" do
              subject.foobar.should == :new_foobar
            end

            describe "being called" do
              it "calls the original method first and sends it into the block" do
                original_return_value = nil
                stub.proxy(subject).foobar {|original_return_value| :new_foobar}
                subject.foobar.should == :new_foobar
                original_return_value.should == :original_foobar
              end
            end

            describe "being reset" do
              before do
                RR::Space.reset_double(subject, :foobar)
              end
              
              it "rebinds the original method" do
                subject.foobar.should == :original_foobar
              end

              it "removes __rr__original_{method_name}" do
                subject.should_not respond_to(:__rr__original_foobar)
              end
            end
          end
        end

        context "when the subject does not have the method defined" do
          describe "being bound" do
            before do
              @subject = Object.new
              def subject.method_missing(method_name, *args, &block)
                if method_name.to_sym == :foobar
                  def self.foobar
                    :original_foobar
                  end
                  foobar
                else
                  super
                end
              end
              def subject.respond_to?(method_name)
                if method_name.to_sym == :foobar
                  true
                else
                  super
                end
              end
              subject.should respond_to(:foobar)
              subject.methods.should_not include('foobar')
              stub.proxy(subject).foobar {:new_foobar}
            end

            it "does not define __rr__original_{method_name}" do
              subject.methods.should_not include("__rr__original_foobar")
            end

            describe "being called" do
              it "defines __rr__original_{method_name} to be the lazily created method" do
                subject.foobar
                subject.methods.should include("__rr__original_foobar")
                subject.__rr__original_foobar.should == :original_foobar
              end

              it "calls the lazily created method and returns the injected method return value" do
                original_return_value = nil
                stub.proxy(subject).foobar {|original_return_value| :new_foobar}
                subject.foobar.should == :new_foobar
                original_return_value.should == :original_foobar
              end
            end
          end
        end
      end

      context "when the subject does not respond to the injected method" do
        describe "being bound" do
          before do
            @subject = Object.new
            subject.should_not respond_to(:foobar)
            subject.methods.should_not include('foobar')
            stub.proxy(subject).foobar {:new_foobar}
          end

          it "adds the method to the subject" do
            subject.should respond_to(:foobar)
            subject.methods.should include('foobar')
          end

          describe "being called" do
            it "raises a NoMethodError" do
              lambda do
                subject.foobar
              end.should raise_error(NoMethodError)
            end
          end

          describe "being reset" do
            before do
              RR::Space.reset_double(subject, :foobar)
            end

            it "unsets the foobar method" do
              subject.should_not respond_to(:foobar)
              subject.methods.should_not include('foobar')
            end
          end
        end
      end

    end
  end
end
