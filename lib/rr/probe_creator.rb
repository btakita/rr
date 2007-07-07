module RR
  # RR::ProbeCreator uses RR::ProbeCreator#method_missing to create
  # a Scenario that acts like a probe.
  #
  # The following example probes method_name with arg1 and arg2
  # returning return_value.
  #
  #   probe(subject).method_name(arg1, arg2) { return_value }
  #
  # The ProbeCreator also supports a block sytnax.
  #
  #    probe(subject) do |m|
  #      m.method_name(arg1, arg2) { return_value }
  #    end
  class ProbeCreator
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
      scenario.with(*args).once.implemented_by(double.original_method)
    end
  end
end
