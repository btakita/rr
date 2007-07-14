module RR
  # RR::MockCreator uses RR::MockCreator#method_missing to create
  # a Scenario that acts like a mock.
  #
  # The following example mocks method_name with arg1 and arg2
  # returning return_value.
  #
  #   mock(subject).method_name(arg1, arg2) { return_value }
  #
  # The MockCreator also supports a block sytnax.
  #
  #    mock(subject) do |m|
  #      m.method_name(arg1, arg2) { return_value }
  #    end
  class MockCreator < Creator
    module InstanceMethods
      protected
      def method_missing(method_name, *args, &returns)
        double = @space.create_double(@subject, method_name)
        scenario = @space.create_scenario(double)
        scenario.with(*args).once.returns(&returns)
        scenario
      end
    end
  end
end
