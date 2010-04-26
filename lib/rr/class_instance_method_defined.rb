module RR
  module ClassInstanceMethodDefined
    def self.call(klass, instance_method)
      klass.method_defined?(instance_method) ||
        klass.protected_method_defined?(instance_method) ||
        klass.private_method_defined?(instance_method)
    end
  end
end