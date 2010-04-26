module RR
  module DoubleDefinitions
    module Scopes
      class NewInstanceOf
        class << self
          include RR::Adapters::RRMethods
          def call(subject_class, stubbed_methods=nil, &block)
            if stubbed_methods
              stub.proxy(subject_class).new do |instance|
                stubbed_methods.each do |name, value|
                  value_proc = value.is_a?(Proc) ? value : lambda {value}
                  stub(instance, name).returns(&value_proc)
                end
                instance
              end
            else
              stub.proxy(subject_class).new do |instance|
                block.call(instance)
              end
            end
          end
        end
      end
    end
  end
end
