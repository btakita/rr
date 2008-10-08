module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class InstanceOfClass < Strategy
          class << self
            def domain_name
              "instance_of"
            end
          end
          DoubleDefinitionCreator.register_scope_strategy_class(self)

          def initialize(*args)
            super

            if !double_definition_creator.no_subject? && !double_definition_creator.subject.is_a?(Class)
              raise ArgumentError, "instance_of only accepts class objects"
            end
          end

          protected
          def do_call
            class_handler = lambda do |return_value|
              double_injection = space.double_injection(return_value, method_name)
              Double.new(double_injection, definition)
              return_value
            end

            instance_of_subject_creator = DoubleDefinitionCreator.new
            instance_of_subject_creator.stub.proxy(subject)
            instance_of_subject_creator.create(:new, &class_handler)
          end
        end
      end
    end
  end
end