module RR
  # RR::MockProbeCreator uses RR::MockProbeCreator#method_missing to create
  # a Scenario that acts like a mock with probing capabilities.
  #
  # Passing a block allows you to intercept the return value.
  # The return value can be modified, validated, and/or overridden by
  # passing in a block. The return value of the block will replace
  # the actual return value.
  #
  #   probe(subject).method_name(arg1, arg2) do |return_value|
  #     return_value.method_name.should == :return_value
  #     my_return_value
  #   end
  #
  #   probe(User) do |m|
  #     m.find('4') do |user|
  #       mock(user).valid? {false}
  #       user
  #     end
  #   end
  #
  #   user = User.find('4')
  #   user.valid? # false
  class MockProbeCreator < ScenarioCreator
    def create(method_name, *args, &after_call)
      double = @space.double(@subject, method_name)
      scenario = @space.scenario(double)
      scenario.with(*args).once.implemented_by(double.original_method)
      scenario.after_call(&after_call) if after_call
      scenario
    end
  end
end
