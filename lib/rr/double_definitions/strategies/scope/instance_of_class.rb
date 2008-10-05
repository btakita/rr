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

            instance_of_subject_builder = Builder.new(double_definition_creator)
            instance_of_subject_builder.verification_strategy = Strategies::Verification::Stub.new
            instance_of_subject_builder.implementation_strategy = Strategies::Implementation::Proxy.new
            instance_of_subject_builder.build(subject, :new, [], class_handler)
          end
        end
      end
    end
  end
end