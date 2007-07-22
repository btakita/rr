module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    attr_reader :space, :subject
    def initialize(space, subject)
      @space = space
      @subject = subject
    end
    
    def create(method_name, *args, &returns)
      double = @space.double(@subject, method_name)
      scenario = @space.scenario(double)
      transform(scenario, *args, &returns)
      scenario
    end
  end
end
