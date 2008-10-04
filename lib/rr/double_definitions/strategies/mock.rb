module RR
  module DoubleDefinitions
    module Strategies
      class Mock < Strategy
        def name
          "mock"
        end

        protected
        def do_call
          definition.with(*args).once
        end  
      end
    end
  end
end