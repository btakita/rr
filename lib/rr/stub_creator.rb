module RR
  class StubCreator
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    
    def initialize(space, subject)
      @space = space
      @subject = subject
      yield(self) if block_given?
    end

    protected
    def method_missing(method_name, *args, &returns)
      double = @space.create_double(@subject, method_name)
      scenario = @space.create_scenario(double)
      scenario.returns(&returns)
      if args.empty?
        scenario.with_any_args
      else
        scenario.with(*args)
      end
    end
  end
end
