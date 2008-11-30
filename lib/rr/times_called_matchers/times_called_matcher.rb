module RR
  module TimesCalledMatchers
    class TimesCalledMatcher #:nodoc:
      class << self
        def create(value)
          return value if value.is_a?(TimesCalledMatcher)
          return IntegerMatcher.new(value) if value.is_a?(Integer)
          return RangeMatcher.new(value) if value.is_a?(Range )
          return ProcMatcher.new(value) if value.is_a?(Proc)
          raise ArgumentError, "There is no TimesCalledMatcher for #{value.inspect}."
        end
      end

      attr_reader :times

      def initialize(times)
        @times = times
      end

      def matches?(times_called)
      end

      def attempt?(times_called)
      end

      def error_message(times_called)
        "Called #{times_called.inspect} #{pluralized_time(times_called)}.\nExpected #{expected_times_message}."
      end

      def ==(other)
        self.class == other.class && self.times == other.times
      end

      def expected_times_message
        "#{@times.inspect} times"
      end

      protected
      def pluralized_time(times_called)
        (times_called == 1) ? "time" : "times"
      end
    end
  end
end