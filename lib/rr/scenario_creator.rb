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
      strategy_error! if @strategy
      @strategy = :mock
    end

    def stub
      strategy_error! if @strategy
      @strategy = :stub
    end

    def probe
      @probe = true
    end

    def mock_probe
      mock
      probe
    end

    def stub_probe
      stub
      probe
    end

    def do_not_call
      @strategy = :do_not_call
    end

    protected
    def transform!
      if @strategy == :mock
        mock!
      elsif @strategy == :stub
        stub!
      elsif @strategy == :do_not_call
        @scenario.never
        permissive_argument!
        reimplementation!
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

    def strategy_error!
      raise(
        ScenarioDefinitionError,
        "This Scenario already has a #{@strategy} strategy."
      )
    end
  end
end
