module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        class InstanceOfClass < Strategy
          def name
            "instance_of"
          end

          protected
          def do_call
            class_handler = lambda do |return_value|
              double_injection = space.double_injection(return_value, method_name)
              Double.new(double_injection, definition)
              return_value
            end

            instance_of_subject_creator = DoubleDefinitionCreator.new
            instance_of_subject_creator.stub.proxy
            instance_of_subject_creator.create(subject, :new, &class_handler)
          end
        end
      end
    end
  end
end