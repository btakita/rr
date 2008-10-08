module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        # This method sets the Double to have a stub strategy. A stub strategy
        # sets the default state of the Double to expect the method call
        # with any arguments any number of times. The Double's
        # expectations can be changed.
        #
        # This method can be chained with proxy.
        #   stub.proxy(subject).method_name_1
        #   or
        #   proxy.stub(subject).method_name_1
        #
        # When passed the subject, a DoubleDefinitionCreatorProxy is returned. Passing
        # a method with arguments to the proxy will set up expectations that
        # the a call to the subject's method with the arguments will happen,
        # and return the prescribed value.
        #   stub(subject).method_name_1 {return_value_1}
        #   stub(subject).method_name_2(arg_1, arg_2) {return_value_2}
        #
        # When passed the subject and the method_name, this method returns
        # a stub Double with the method already set.
        #
        #   mock(subject, :method_name_1) {return_value_1}
        #   mock(subject, :method_name_2).with(arg1, arg2) {return_value_2}
        #
        # stub also takes a block for definitions.
        #   stub(subject) do
        #     method_name_1 {return_value_1}
        #     method_name_2(arg_1, arg_2) {return_value_2}
        #   end        
        class Stub < VerificationStrategy
          register "stub"

          protected
          def do_call
            definition.any_number_of_times
            permissive_argument
          end
        end
      end
    end
  end
end