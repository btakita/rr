module RR
  # RR::ProbeCreator uses RR::ProbeCreator#method_missing to create
  # a Scenario that acts like a probe.
  #
  # The following example probes method_name with arg1 and arg2
  # returning the actual value of the method. The block is an after callback
  # that intercepts the return value. Mocks or other modifications can
  # be done to the return value.
  #
  #   probe(subject).method_name(arg1, arg2) { |return_value| }
  #
  # The ProbeCreator also supports a block sytnax. The block accepts
  # a after_call callback, instead of a return value as with MockCreator
  # and StubCreator.
  #
  #    probe(User) do |m|
  #      m.find('4') do |user|
  #        mock(user).valid? {false}
  #      end
  #    end
  #
  #   user = User.find('4')
  #   user.valid? # false
  class ProbeCreator < Creator
    module InstanceMethods
      protected
      def method_missing(method_name, *args, &after_call)
        double = @space.create_double(@subject, method_name)
        scenario = @space.create_scenario(double)
        scenario.with(*args).once.implemented_by(double.original_method)
        scenario.after_call(&after_call) if after_call
        scenario
      end      
    end
  end
end
