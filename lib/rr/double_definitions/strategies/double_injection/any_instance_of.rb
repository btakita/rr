module RR
  module DoubleDefinitions
    module Strategies
      module DoubleInjection
        # This class is Deprecated.
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
        class AnyInstanceOf < DoubleInjectionStrategy
          protected
          def do_call
            if !double_definition_create.no_subject? && !double_definition_create.subject.is_a?(Class)
              raise ArgumentError, "instance_of only accepts class objects"
            end
            double_injection = Injections::DoubleInjection.find_or_create(subject, method_name)
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end