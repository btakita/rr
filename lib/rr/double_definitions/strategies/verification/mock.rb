module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        # This method sets the Double to have a mock strategy. A mock strategy
        # sets the default state of the Double to expect the method call
        # with arguments exactly one time. The Double's expectations can be
        # changed.
        #
        # This method can be chained with proxy.
        #   mock.proxy(subject).method_name_1
        #   or
        #   proxy.mock(subject).method_name_1
        #
        # When passed the subject, a DoubleDefinitionCreatorProxy is returned. Passing
        # a method with arguments to the proxy will set up expectations that
        # the a call to the subject's method with the arguments will happen,
        # and return the prescribed value.
        #   mock(subject).method_name_1 {return_value_1}
        #   mock(subject).method_name_2(arg1, arg2) {return_value_2}
        #
        # When passed the subject and the method_name, this method returns
        # a mock Double with the method already set.
        #
        #   mock(subject, :method_name_1) {return_value_1}
        #   mock(subject, :method_name_2).with(arg1, arg2) {return_value_2}
        #
        # mock also takes a block for definitions.
        #   mock(subject) do
        #     method_name_1 {return_value_1}
        #     method_name_2(arg_1, arg_2) {return_value_2}
        #   end        
        class Mock < VerificationStrategy
          register "mock"

          protected
          def do_call
            definition.with(*args).once
          end
        end
      end
    end
  end
end