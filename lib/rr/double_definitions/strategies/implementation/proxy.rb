module RR
  module DoubleDefinitions
    module Strategies
      module Implementation
        # This method add proxy capabilities to the Double. proxy can be called
        # with mock or stub.
        #
        #   mock.proxy(controller.template).render(:partial => "my/socks")
        #
        #   stub.proxy(controller.template).render(:partial => "my/socks") do |html|
        #     html.should include("My socks are wet")
        #     html
        #   end
        #
        #   mock.proxy(controller.template).render(:partial => "my/socks") do |html|
        #     html.should include("My socks are wet")
        #     "My new return value"
        #   end
        #
        # mock.proxy also takes a block for definitions.
        #   mock.proxy(subject) do
        #     render(:partial => "my/socks")
        #
        #     render(:partial => "my/socks") do |html|
        #       html.should include("My socks are wet")
        #       html
        #     end
        #
        #     render(:partial => "my/socks") do |html|
        #       html.should include("My socks are wet")
        #       html
        #     end
        #
        #     render(:partial => "my/socks") do |html|
        #       html.should include("My socks are wet")
        #       "My new return value"
        #     end
        #   end
        #
        # Passing a block to the Double (after the method name and arguments)
        # allows you to intercept the return value.
        # The return value can be modified, validated, and/or overridden by
        # passing in a block. The return value of the block will replace
        # the actual return value.
        #
        #   mock.proxy(controller.template).render(:partial => "my/socks") do |html|
        #     html.should include("My socks are wet")
        #     "My new return value"
        #   end        
        class Proxy < ImplementationStrategy
          register("proxy", :probe)

          protected
          def do_call
            definition.implemented_by_original_method
            definition.after_call(&handler) if handler
          end
        end
      end
    end
  end
end