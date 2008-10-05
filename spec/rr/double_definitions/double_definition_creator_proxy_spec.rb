require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

module RR
  module DoubleDefinitions
    describe DoubleDefinitionCreatorProxy do
      attr_reader :space, :subject, :creator, :the_proxy
      it_should_behave_like "Swapped Space"

      before(:each) do
        @subject = Object.new
        @creator = DoubleDefinitionCreator.new
        creator.mock
      end

      class << self
        define_method("initializes proxy with passed in creator") do
          it "initializes proxy with passed in creator" do
            class << the_proxy
              attr_reader :creator
            end
            the_proxy.creator.should === creator
          end
        end
      end

      describe ".new" do
        it "does not undefine object_id" do
          the_proxy = DoubleDefinitionCreatorProxy.new(creator, subject)
          the_proxy.object_id.class.should == Fixnum
        end

        context "without block" do
          before do
            @the_proxy = DoubleDefinitionCreatorProxy.new(creator, subject)
          end

          send "initializes proxy with passed in creator"

          it "clears out all methods from proxy" do
            proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
              def i_should_be_a_double
              end
            end
            proxy_subclass.instance_methods.map {|m| m.to_s}.should include('i_should_be_a_double')

            proxy = proxy_subclass.new(creator, subject)
            proxy.i_should_be_a_double.should be_instance_of(DoubleDefinition)
          end
        end

        context "with block" do
          before do
            @the_proxy = DoubleDefinitionCreatorProxy.new(creator, subject) do |b|
              b.foobar(1, 2) {:one_two}
              b.foobar(1) {:one}
              b.foobar.with_any_args {:default}
              b.baz() {:baz_result}
            end
          end

          # send "initializes proxy with passed in creator"

          it "creates double_injections" do
            subject.foobar(1, 2).should == :one_two
            subject.foobar(1).should == :one
            subject.foobar(:something).should == :default
            subject.baz.should == :baz_result
          end

          it "clears out all methods from proxy" do
            proxy_subclass = Class.new(DoubleDefinitionCreatorProxy) do
              def i_should_be_a_double
              end
            end
            proxy_subclass.instance_methods.map {|m| m.to_s}.should include('i_should_be_a_double')

            proxy_subclass.new(creator, subject) do |m|
              m.i_should_be_a_double.should be_instance_of(DoubleDefinition)
            end
          end
        end
      end
    end    
  end
end