module RR
  module DoubleDefinitions
    module Strategies
      module Verification
        # This method sets the Double to have a dont_allow strategy.
        # A dont_allow strategy sets the default state of the Double
        # to expect never to be called. The Double's expectations can be
        # changed.
        #
        # The following example sets the expectation that subject.method_name
        # will never be called with arg1 and arg2.
        #
        #   do_not_allow(subject).method_name(arg1, arg2)
        #
        # dont_allow also supports a block sytnax.
        #    dont_allow(subject) do |m|
        #      m.method1 # Do not allow method1 with any arguments
        #      m.method2(arg1, arg2) # Do not allow method2 with arguments arg1 and arg2
        #      m.method3.with_no_args # Do not allow method3 with no arguments
        #    end        
        class DontAllow < VerificationStrategy
          register("dont_allow", :do_not_allow, :dont_call, :do_not_call)

          protected
          def do_call
            definition.never
            permissive_argument
            reimplementation
          end
        end
      end
    end
  end
end