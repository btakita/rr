module RR
  module DoubleDefinitions
    module Scopes
      class NewInstanceOf
        class << self
          include RR::Adapters::RRMethods
          def call(subject_class, stubbed_methods={})
            DoubleDefinitionCreate.stub
            double_definition = DoubleDefinition.new

            stub(subject_class).new do |*args|
              stubbed_methods.each do |name, value|
                value_proc = value.is_a?(Proc) ? value : lambda {value}
                stub(subject_instance, name).returns(&value_proc)
              end
              yield(subject_instance) if block_given?
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
end
