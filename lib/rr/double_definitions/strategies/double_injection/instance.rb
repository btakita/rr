module RR
  module DoubleDefinitions
    module Strategies
      module DoubleInjection
        class Instance < DoubleInjectionStrategy
          protected
          def do_call
            double_injection = Injections::DoubleInjection.find_or_create(
              (class << subject; self; end), method_name
            )
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end