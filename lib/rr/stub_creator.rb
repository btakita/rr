module RR
  # RR::StubCreator uses RR::StubCreator#method_missing to create
  # a Scenario that acts like a stub.
  #
  # The following example stubs method_name with arg1 and arg2
  # returning return_value.
  #
  #   stub(subject).method_name(arg1, arg2) { return_value }
  #
  # The StubCreator also supports a block sytnax.
  #
  #    stub(subject) do |m|
  #      m.method_name(arg1, arg2) { return_value }
  #    end
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
      scenario.returns(&returns).any_number_of_times
      if args.empty?
        scenario.with_any_args
      else
        scenario.with(*args)
      end
    end
  end
end
