module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    attr_reader :space, :subject
    include Errors

    def initialize(space, subject)
      @space = space
      @subject = subject
      @strategy = nil
      @probe = false
      @do_not_call = false
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
      if @strategy == :stub
        raise(
          ScenarioDefinitionError,
          "This Scenario is already a stub. It cannot be a mock."
        )
      end
      @strategy = :mock
    end

    def stub
      @strategy = :stub
    end

    def mock_probe
      @strategy = :mock
      @probe = true
    end

    def stub_probe
      @strategy = :stub
      @probe = true
    end

    def do_not_call
      @do_not_call = true
    end

    protected
    def transform!
      if @do_not_call
        @scenario.never
        permissive_argument!
        reimplementation!
        return
      end

      if @strategy == :mock
        mock!
      elsif @strategy == :stub
        stub!
      end
      
      if @probe
        probe!
      else
        reimplementation!
      end
    end

    def mock!
      @scenario.with(*@args).once
    end

    def stub!
      @scenario.any_number_of_times
      permissive_argument!
    end

    def permissive_argument!
      if @args.empty?
        @scenario.with_any_args
      else
        @scenario.with(*@args)
      end
    end

    def reimplementation!
      @scenario.returns(&@handler)
    end
    
    def probe!
      @scenario.implemented_by_original_method
      @scenario.after_call(&@handler) if @handler
    end
  end
end
