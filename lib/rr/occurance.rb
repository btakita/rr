module RR
  class Occurance
    attr_reader :space, :double, :arguments
    def initialize(space, double, arguments)
      @space = space
      @double = double
      @arguments = arguments
    end
  end
end
