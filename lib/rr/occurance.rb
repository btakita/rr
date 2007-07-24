module RR
  class Occurance
    attr_reader :space, :double, :scenario
    def initialize(space, double, scenario)
      @space = space
      @double = double
      @scenario = scenario
    end
  end
end
