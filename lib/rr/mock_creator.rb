module RR
  class MockCreator
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    
    def initialize(space, *args)
      @space = space
      arg_length = args.length
      raise ArgumentError, "wrong number of arguments (#{arg_length} for 1)" if arg_length > 1
      @subject = args.first || Object.new
    end

    protected
    def method_missing(method_name, *args, &returns)
      scenario = @space.create_scenario(@subject, method_name)
      scenario.returns(&returns)
      scenario.double.add_expectation(Expectations::ArgumentEqualityExpectation.new(*args))
      scenario.double.add_expectation(Expectations::TimesCalledExpectation.new(1))
      scenario
    end
  end
end
