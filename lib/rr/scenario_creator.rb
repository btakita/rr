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
        mock_transform!
        reimplementation_transform!
      when :stub
        stub_transform!
        reimplementation_transform!
      when :mock_probe
        mock_transform!
        probe_transform!
      when :stub_probe
        stub_transform!
        probe_transform!
      when :do_not_call
        @scenario.never
        permissive_argument_transform!
        reimplementation_transform!
      end
    end

    def reimplementation_transform!
      @scenario.returns(&@handler)
    end

    def mock_transform!
      @scenario.with(*@args).once
    end

    def stub_transform!
      @scenario.any_number_of_times
      permissive_argument_transform!
    end

    def permissive_argument_transform!
      if @args.empty?
        @scenario.with_any_args
      else
        @scenario.with(*@args)
      end
    end
    
    def probe_transform!
      @scenario.implemented_by_original_method
      @scenario.after_call(&@handler) if @handler
    end
  end
end
