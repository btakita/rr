module RR
  module DoubleDefinitions
    module Scopes
      class AnyInstanceOf
        extend(Module.new do
          include RR::Adapters::RRMethods

          def call(subject_class, stubbed_methods=nil, &block)
            if stubbed_methods
              memoized_subject_class_original_methods = subject_class_original_methods
              memoized_subject_class_original_methods[subject_class] ||= {}
              subject_class.class_eval do
                stubbed_methods.each do |name, value|
                  unless memoized_subject_class_original_methods[subject_class].has_key?(name)
                    if method_defined?(name) || protected_method_defined?(name) || private_method_defined?(name)
                      memoized_subject_class_original_methods[subject_class][name] = instance_method(name)
                    else
                      memoized_subject_class_original_methods[subject_class][name] = nil
                    end
                  end
                  value_proc = value.is_a?(Proc) ? value : lambda {value}
                  define_method(name, &value_proc)
                end
              end
            else
              prototype = PrototypeSubject.new
              block.call(prototype)
              prototype.double_definition
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
