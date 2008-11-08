module RR
  module DoubleDefinitions
    module Strategies
      module Scope
        # Calling instance_of will cause all instances of the passed in Class
        # to have the Double defined.
        #
        # The following example mocks all User's valid? method and return false.
        #   mock.instance_of(User).valid? {false}
        #
        # The following example mocks and proxies User#projects and returns the
        # first 3 projects.
        #   mock.instance_of(User).projects do |projects|
        #     projects[0..2]
        #   end        
        class InstanceOfClass < ScopeStrategy
          register "instance_of"

          def initialize(*args)
            super

            if !double_definition_creator.no_subject? && !double_definition_creator.subject.is_a?(Class)
              raise ArgumentError, "instance_of only accepts class objects"
            end
          end

          protected
          def do_call
            class_handler = lambda do |return_value|
              #####
              double_injection = space.double_injection(return_value, method_name)
              Double.new(double_injection, definition)
              #####
              return_value
            end

            instance_of_subject_creator = DoubleDefinitionCreator.new
            instance_of_subject_creator.strong if definition.verify_method_signature?
            instance_of_subject_creator.stub.proxy(subject)
            instance_of_subject_creator.create(:new, &class_handler)
          end
        end
      end
    end
  end
end