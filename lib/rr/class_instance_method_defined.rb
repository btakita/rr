module RR
  module ClassInstanceMethodDefined
    def self.call(klass, instance_method, include_super=true)
      klass.instance_methods(include_super).detect {|method_name| method_name.to_sym == instance_method.to_sym} ||
        klass.protected_instance_methods(include_super).detect {|method_name| method_name.to_sym == instance_method.to_sym} ||
        klass.private_instance_methods(include_super).detect {|method_name| method_name.to_sym == instance_method.to_sym}
    end
  end
end