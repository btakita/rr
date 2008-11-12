module RR
  class Invocation
    attr_reader :args, :times_called

    def initialize(args)
      @args = args
      @times_called = 0
    end

    def called?(matcher)
      matcher.matches?(@times_called)
    end

    def invoke
      @times_called += 1
    end
  end
end
