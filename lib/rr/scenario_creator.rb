module RR
  # RR::ScenarioCreator is the superclass for all creators.
  class ScenarioCreator
    attr_reader :space, :subject
    def initialize(space, subject)
      @space = space
      @subject = subject
    end
  end
end
