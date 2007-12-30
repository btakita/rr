module RR
  module TimesCalledMatchers
    class ProcMatcher < TimesCalledMatcher #:nodoc:
      include NonTerminal

      def matches?(times_called)
        @times.call(times_called)
      end
    end
  end
end