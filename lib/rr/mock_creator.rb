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
  class MockCreator < ScenarioCreator
    def transform(scenario, *args, &returns)
      scenario.with(*args).once.returns(&returns)
    end
  end
end
