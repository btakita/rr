module RR
  class MockCreationProxy
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    
    def initialize(space, *args)
      @space = space
      arg_length = args.length
      raise ArgumentError, "wrong number of arguments (#{arg_length} for 1)" if arg_length > 1
      @subject = args.first || Object.new
    end

    protected
    def method_missing(method_name, *args, &returns)
      double = @space.create_double(@subject, method_name, &returns)
      double.add_expectation(Expectations::ArgumentEqualityExpectation.new(*args))
      double.add_expectation(Expectations::TimesCalledExpectation.new(1))
      double
    end
  end
end
