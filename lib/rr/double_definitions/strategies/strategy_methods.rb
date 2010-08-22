module RR
  module DoubleDefinitions
    module Strategies
      module StrategyMethods
        extend(Module.new do
          def lately_bound_alias_method(target_method_name, source_method_name)
            module_eval((<<-METHOD), __FILE__, __LINE__+1)
            def #{target_method_name}(*args, &block)
              #{source_method_name}(*args, &block)
            end
            METHOD
          end
        end)

        def mock!(method_name=nil, &definition_eval_block)
          mock(Object.new, method_name, &definition_eval_block)
        end

        def stub!(method_name=nil, &definition_eval_block)
          stub(Object.new, method_name, &definition_eval_block)
        end

        def dont_allow!(method_name=nil, &definition_eval_block)
          dont_allow(Object.new, method_name, &definition_eval_block)
        end
        lately_bound_alias_method :do_not_allow, :dont_allow
        lately_bound_alias_method :do_not_allow!, :dont_allow!

        def proxy!(method_name=nil, &definition_eval_block)
          proxy(Object.new, method_name, &definition_eval_block)
        end
        lately_bound_alias_method :probe, :proxy
        lately_bound_alias_method :probe!, :proxy!

        def strong!(method_name=nil, &definition_eval_block)
          strong(Object.new, method_name, &definition_eval_block)
        end

        def any_instance_of!(method_name=nil, &definition_eval_block)
          any_instance_of(Object.new, method_name, &definition_eval_block)
        end
        lately_bound_alias_method :all_instances_of, :any_instance_of
        lately_bound_alias_method :all_instances_of!, :any_instance_of!

        def instance_of!(method_name=nil, &definition_eval_block)
          instance_of(Object.new, method_name, &definition_eval_block)
        end
        lately_bound_alias_method :new_instance_of, :instance_of
        lately_bound_alias_method :new_instance_of!, :instance_of!
      end
    end
  end
end
