module RR
  # TODO: Refactor to a side-effect-free strategy.
  class HashWithObjectIdKey < ::Hash #:nodoc:
    def initialize
      @keys = {}
      super
    end

    alias_method :get_with_object_id, :[]

    def [](key)
      @keys[key.__id__] = key
      super(key.__id__)
    end

    def has_key?(key)
      super(key.__id__)
    end

    alias_method :set_with_object_id, :[]=

    def []=(key, value)
      @keys[key.__id__] = key
      super(key.__id__, value)
    end

    def each
      super do |object_id, value|
        yield @keys[object_id], value
      end
    end

    def delete(key)
      @keys.delete(key.__id__)
      super(key.__id__)
    end

    def keys
      @keys.values
    end

    def include?(key)
      super(key.__id__)
    end
  end
end