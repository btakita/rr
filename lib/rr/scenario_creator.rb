module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    attr_reader :space, :subject
    def initialize(space, subject)
      @space = space
      @subject = subject
      @strategy = nil
    end
    
    def create!(method_name, *args, &handler)
      @method_name = method_name
      @args = args
      @handler = handler
      @double = @space.double(@subject, method_name)
      @scenario = @space.scenario(@double)
      transform!
      @scenario
    end

    def mock
      @strategy = :mock
    end

    def stub
      @strategy = :stub
    end

    def mock_probe
      @strategy = :mock_probe
    end

    def stub_probe
      @strategy = :stub_probe
    end

    def do_not_call
      @strategy = :do_not_call
    end

    protected
    def transform!
      case @strategy
      when :mock
        @scenario.with(*@args).once.returns(&@handler)
      when :stub
        @scenario.returns(&@handler).any_number_of_times
        permissive_argment_strategy
      when :mock_probe
        @scenario.with(*@args).once
        probe_strategy
      when :stub_probe
        @scenario.any_number_of_times
        permissive_argment_strategy
        probe_strategy
      when :do_not_call
        permissive_argment_strategy
        @scenario.never.returns(&@handler)
      end
    end

    def permissive_argment_strategy
      if @args.empty?
        @scenario.with_any_args
      else
        @scenario.with(*@args)
      end
    end
    
    def probe_strategy
      @scenario.implemented_by_original_method
      @scenario.after_call(&@handler) if @handler
    end
  end
end
