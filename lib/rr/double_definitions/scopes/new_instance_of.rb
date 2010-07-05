module RR
  module DoubleDefinitions
    module Scopes
      class NewInstanceOf
        class << self
          include RR::Adapters::RRMethods
          def call(subject_class, stubbed_methods={})
            double_definition_create = DoubleDefinitionCreate.new.stub
            stub(subject_class).new do |*args|
              subject_instance = subject_class.allocate
              add_stubbed_methods(subject_instance, stubbed_methods)
              add_method_chain_definition(subject_instance, double_definition_create)
              yield(subject_instance) if block_given?
              initialize_subject_instance(subject_instance, args)
            end
            DoubleDefinitionCreateBlankSlate.new(double_definition_create)
          end

          protected
          def add_stubbed_methods(subject_instance, stubbed_methods)
            stubbed_methods.each do |name, value|
              value_proc = value.is_a?(Proc) ? value : lambda {value}
              stub(subject_instance, name).returns(&value_proc)
            end
          end

          def add_method_chain_definition(subject_instance, double_definition_create)
            if double_definition_create.implementation_strategy.method_name
              stub(subject_instance).method_missing(
                double_definition_create.implementation_strategy.method_name,
                *double_definition_create.implementation_strategy.args,
                &double_definition_create.implementation_strategy.handler
              )
            end
          end

          def initialize_subject_instance(subject_instance, args)
            if args.last.is_a?(ProcFromBlock)
              subject_instance.__send__(:initialize, *args[0..(args.length-2)], &args.last)
            else
              subject_instance.__send__(:initialize, *args)
            end
            subject_instance
          end
        end
      end
    end
  end
end
