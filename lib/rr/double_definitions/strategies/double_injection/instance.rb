module RR
  module DoubleDefinitions
    module Strategies
      module DoubleInjection
        class Instance < DoubleInjectionStrategy
          protected
          def do_call
            double_injection = Injections::DoubleInjection.find_or_create(
              subject, method_name, (class << subject; self; end)
            )
            Double.new(double_injection, definition)
          end
        end
      end
    end
  end
end