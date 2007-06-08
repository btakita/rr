module RR
  class Space
    class << self
      def instance
        @instance ||= new
      end
      attr_writer :instance
      
      protected
      def method_missing(method_name, *args, &block)
        instance.__send__(method_name, *args, &block)
      end
    end

    attr_reader :doubles
    def initialize
      @doubles = Hash.new {|hash, key| hash[key] = Hash.new}
    end

    def create_double(object, method_name, &implementation)
      double = Double.new(self, object, method_name.to_sym)
      @doubles[object][method_name.to_sym] = double
      double.override(&implementation) if implementation
      double
    end

    def verify_double(object, method_name)
      @doubles[object][method_name].verify
      reset_double object, method_name
    end

    def reset_double(object, method_name)
      double = @doubles[object].delete(method_name)
      double.reset
    end
  end
end