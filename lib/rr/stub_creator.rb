module RR
  class StubCreator
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    
    def initialize(space, *args)
      @space = space
      arg_length = args.length
      raise ArgumentError, "wrong number of arguments (#{arg_length} for 1)" if arg_length > 1
      @subject = args.first || Object.new
    end

    protected
    def method_missing(method_name, *args, &returns)
      proxy = @space.create_scenario_builder(@subject, method_name, &returns)
      proxy.with(Expectations::ArgumentEqualityExpectation::Anything.new)
    end
  end
end
