module RR
  module DoubleDefinitions
    module DoubleInjections
      class AnyInstanceOf
        extend(Module.new do
          include RR::Adapters::RRMethods

          def call(subject_class, stubbed_methods=nil, &block)
            ::RR::DoubleDefinitions::DoubleDefinitionCreate.set_default_double_injection_strategy(lambda do |double_definition_create|
              ::RR::DoubleDefinitions::Strategies::DoubleInjection::AnyInstanceOf.new(double_definition_create)
            end) do
              if stubbed_methods
                memoized_subject_class_original_methods = subject_class_original_methods
                memoized_subject_class_original_methods[subject_class] ||= {}
                subject_class.class_eval do
                  stubbed_methods.each do |name, value|
                    value_proc = value.is_a?(Proc) ? value : lambda {value}
                    RR.stub(subject_class, name).returns(&value_proc)
                  end
                end
              else
                prototype = PrototypeSubject.new
                block.call(prototype)
                prototype.double_definition
              end
            end
          end

          def subject_class_original_methods
            @subject_class_original_methods ||= {}
          end

          def reset
            subject_class_original_methods.each do |subject_class, original_methods|
              subject_class.class_eval do
                original_methods.each do |method_name, implementation|
                  if implementation
                    define_method(method_name, implementation)
                  else
                    remove_method(method_name)
                  end
                  original_methods.delete(method_name)
                end
              end
              subject_class_original_methods.delete(subject_class)
            end
          end
        end)
      end
    end
  end
end
