module RR
  class DoubleInjectionDispatch
    include Space::Reader

    attr_reader :double_injection, :args, :block, :double

    def initialize(double_injection, args, block)
      @double_injection, @args, @block = double_injection, args, block
      @double = find_double_to_attempt
    end

    def call
      space.record_call(subject, method_name, args, block)
      if double
        call_double
      else
        double_not_found_error
      end
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

    def call_double
      double.method_call(args)
      call_yields
      return_value = call_implementation
      definition.after_call_proc ? extract_subject_from_return_value(definition.after_call_proc.call(return_value)) : return_value
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

    def call_implementation
      return_value = get_implementation_return_value
      extract_subject_from_return_value(return_value)
    end

    def get_implementation_return_value
      if implementation_is_original_method?
        call_original_method
      else
        if implementation
          if implementation.is_a?(Method)
            implementation.call(*args, &block)
          else
            call_args = block ? args + [ProcFromBlock.new(&block)] : args
            implementation.call(*call_args)
          end
        else
          nil
        end
      end
    end

    def implementation_is_original_method?
      double.implementation_is_original_method?
    end

    def call_original_method
      if subject_has_original_method?
        double_injection.call_original_method(args, block)
      else
        double_injection.call_method_missing(args, block)
      end
    end

    def extract_subject_from_return_value(return_value)
      case return_value
        when DoubleDefinitions::DoubleDefinition
          return_value.root_subject
        when DoubleDefinitions::DoubleDefinitionCreatorProxy
          return_value.__creator__.root_subject
        else
          return_value
      end
    end

    def implementation
      definition.implementation
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

    def subject_has_original_method?
      double_injection.subject_has_original_method?
    end

    def subject
      double_injection.subject
    end

    def method_name
      double_injection.method_name
    end

    def doubles
      double_injection.doubles
    end

    def definition
      double.definition
    end
  end
end
