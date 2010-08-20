module RR
  module BlankSlate
    extend(Module.new do
      def call(klass)
        klass.instance_eval do
          instance_methods.each do |unformatted_method_name|
            method_name = unformatted_method_name.to_s
            unless method_name =~ /^_/ || Space.blank_slate_whitelist.any? {|whitelisted_method_name| method_name == whitelisted_method_name}
              alias_method "__blank_slated_#{method_name}", method_name
              undef_method method_name
            end
          end
        end
      end
    end)
  end
end