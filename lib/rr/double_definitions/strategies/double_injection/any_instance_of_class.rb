module RR
  module DoubleDefinitions
    module Strategies
      module DoubleInjection
        # Calling any_instance_of will cause all instances of the passed in Class
        # to have the Double defined.
        #
        # The following example mocks all User's valid? method and return false.
        #   mock.any_instance_of(User).valid? {false}
        #
        # The following example mocks and proxies User#projects and returns the
        # first 3 projects.
        #   mock.any_instance_of(User).projects do |projects|
        #     projects[0..2]
        #   end        
        class AnyInstanceOfClass < InstanceOfClass
          protected
          def do_call
            ObjectSpace.each_object(subject) do |object|
              add_double_to_instance(object)
            end
            super
          end
          
          def add_double_to_instance(instance, *args)
            double_injection = Injections::DoubleInjection.find_or_create(instance, method_name)
            Double.new(double_injection, definition)
            #####
            if args.last.is_a?(ProcFromBlock)
              instance.__send__(:initialize, *args[0..(args.length-2)], &args.last)
            else
              instance.__send__(:initialize, *args)
            end
            instance
          end  
        end
      end
    end
  end
end