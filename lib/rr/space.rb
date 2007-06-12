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
      @doubles = Hash.new {|hash, subject_object| hash[subject_object] = Hash.new}
    end

    def create_expectation_proxy(object, method_name, &implementation)
      double = create_double(object, method_name, &implementation)
      ExpectationProxy.new(double)
    end

    def create_double(object, method_name, &implementation)
      if old_double = @doubles[object][method_name.to_sym]
        old_double.reset
      end
      double = Double.new(self, object, method_name.to_sym)
      @doubles[object][method_name.to_sym] = double
      double.returns(&implementation) if implementation
      double
    end

    def verify_doubles
      @doubles.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          verify_double(object, method_name)
        end
      end
    end

    def reset_doubles
      @doubles.each do |object, method_double_map|
        method_double_map.keys.each do |method_name|
          reset_double(object, method_name)
        end
      end
    end

    def verify_double(object, method_name)
      @doubles[object][method_name].verify
      reset_double object, method_name
    end

    def reset_double(object, method_name)
      double = @doubles[object].delete(method_name)
      @doubles.delete(object) if @doubles[object].empty?
      double.reset
    end
  end
end