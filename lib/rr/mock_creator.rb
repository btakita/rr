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
      proxy = @space.create_expectation_proxy(@subject, method_name, &returns)
      proxy.double.add_expectation(Expectations::ArgumentEqualityExpectation.new(*args))
      proxy.double.add_expectation(Expectations::TimesCalledExpectation.new(1))
      proxy
    end
  end
end
