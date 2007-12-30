module RR
  module TimesCalledMatchers
    class RangeMatcher < TimesCalledMatcher #:nodoc:
      include Terminal

      def possible_match?(times_called)
        return true if times_called < @times.begin
        return true if @times.include?(times_called)
        return false
      end

      def matches?(times_called)
        @times.include?(times_called)
      end

      def attempt?(times_called)
        possible_match?(times_called)
      end
    end
  end
end