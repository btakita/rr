module RR
  class DoubleMatches
    attr_reader :matching_doubles,
                :exact_terminal_doubles_to_attempt,
                :exact_non_terminal_doubles_to_attempt,
                :wildcard_terminal_doubles_to_attempt,
                :wildcard_non_terminal_doubles_to_attempt
    def initialize(doubles) #:nodoc:
      @doubles = doubles
      @matching_doubles = []
      @exact_terminal_doubles_to_attempt = []
      @exact_non_terminal_doubles_to_attempt = []
      @wildcard_terminal_doubles_to_attempt = []
      @wildcard_non_terminal_doubles_to_attempt = []
    end

    def find_all_matches(args)
      @doubles.each do |double|
        if double.exact_match?(*args)
          matching_doubles << double
          if double.attempt?
            exact_double_is_terminal_or_non_terminal double
          end
        elsif double.wildcard_match?(*args)
          matching_doubles << double
          if double.attempt?
            wildcard_double_is_terminal_or_non_terminal double
          end
        end
      end
      self
    end

    protected
    def exact_double_is_terminal_or_non_terminal(double)
      if double.terminal?
        exact_terminal_doubles_to_attempt << double
      else
        exact_non_terminal_doubles_to_attempt << double
      end
    end

    def wildcard_double_is_terminal_or_non_terminal(double)
      if double.terminal?
        wildcard_terminal_doubles_to_attempt << double
      else
        wildcard_non_terminal_doubles_to_attempt << double
      end
    end
  end
end