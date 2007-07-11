module RR
  module Expectations
    class AtLeastTimesCalledExpectation
      attr_reader :times, :times_called
      
      def initialize(times=0)
        @at_least = times
        @times_called= 0
        @verify_backtrace = caller[1..-1]
      end

      def verify_input
        @times_called += 1
      end

      def verify
        return @times_called >= @at_least
      end

      def verify!
        unless verify
          if @verify_backtrace
            error = Errors::TimesCalledError.new(error_message)
            error.backtrace = @verify_backtrace
            raise error
          else
            raise Errors::TimesCalledError, error_message
          end
        end
        true
      end

      protected
      def error_message
        time_casing = (@times_called == 1) ? "time" : "times"
        "Called #{@times_called.inspect} #{time_casing}. Expected #{@times.inspect}."
      end
    end
  end
end