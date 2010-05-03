module RR
  module MethodDispatches
    class BaseMethodDispatch
      extend Forwardable
      include Space::Reader

      attr_reader :args, :block, :double

      def call
        raise NotImplementedError
      end

      protected
      def find_double_to_attempt
        matches = DoubleMatches.new(doubles).find_all_matches(args)

        unless matches.exact_terminal_doubles_to_attempt.empty?
          return matches.exact_terminal_doubles_to_attempt.first
        end

        unless matches.exact_non_terminal_doubles_to_attempt.empty?
          return matches.exact_non_terminal_doubles_to_attempt.last
        end

        unless matches.wildcard_terminal_doubles_to_attempt.empty?
          return matches.wildcard_terminal_doubles_to_attempt.first
        end

        unless matches.wildcard_non_terminal_doubles_to_attempt.empty?
          return matches.wildcard_non_terminal_doubles_to_attempt.last
        end

        unless matches.matching_doubles.empty?
          return matches.matching_doubles.first # This will raise a TimesCalledError
        end

        return nil
      end

      def call_yields
        if definition.yields_value
          if block
            block.call(*definition.yields_value)
          else
            raise ArgumentError, "A Block must be passed into the method call when using yields"
          end
        end
      end

      def call_original_method_missing
        subject.__send__(MethodMissingDispatch.original_method_missing_alias_name, method_name, *args, &block)
      end

      def implementation_is_original_method?
        double.implementation_is_original_method?
      end

      def extract_subject_from_return_value(return_value)
        case return_value
          when DoubleDefinitions::DoubleDefinition
            return_value.root_subject
          when DoubleDefinitions::DoubleDefinitionCreateBlankSlate
            return_value.__double_definition_create__.root_subject
          else
            return_value
        end
      end

      def double_not_found_error
        message =
          "On subject #{subject},\n" <<
          "unexpected method invocation:\n" <<
          "  #{Double.formatted_name(method_name, args)}\n" <<
          "expected invocations:\n" <<
          Double.list_message_part(doubles)
        raise Errors::DoubleNotFoundError, message
      end

      def_delegators :definition, :after_call_proc
      def_delegators :double, :definition
      def_delegators :double_injection, :doubles
    end
  end
end
