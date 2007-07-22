module RR
  # RR::DoNotAllowCreator uses RR::DoNotAllowCreator#method_missing to create
  # a Scenario that expects never to be called.
  #
  # The following example mocks method_name with arg1 and arg2
  # returning return_value.
  #
  #   do_not_allow(subject).method_name(arg1, arg2) { return_value }
  #
  # The DoNotAllowCreator also supports a block sytnax.
  #
  #    do_not_allow(subject) do |m|
  #      m.method1 # Do not allow method1 with any arguments
  #      m.method2(arg1, arg2) # Do not allow method2 with arguments arg1 and arg2
  #      m.method3.with_no_args # Do not allow method3 with no arguments
  #    end
  class DoNotAllowCreator < ScenarioCreator
    def create(method_name, *args, &returns)
      double = @space.create_double(@subject, method_name)
      scenario = @space.scenario(double)
      if args.empty?
        scenario.with_any_args
      else
        scenario.with(*args)
      end
      scenario.never.returns(&returns)
      scenario
    end
  end
end
