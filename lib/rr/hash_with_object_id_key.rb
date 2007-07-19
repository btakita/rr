module RR
class HashWithObjectIdKey < ::Hash
  alias_method :get_with_object_id, :[]
  def [](key)
    super(key.__id__)
  end

  alias_method :set_with_object_id, :[]=
  def []=(key, value)
    super(key.__id__, value)
  end

  def each
    super do |object_id, value|
      yield ObjectSpace._id2ref(object_id), value
    end
  end

  def delete(key)
    super(key.__id__)
  end

  def keys
    raw_keys = super
    raw_keys.collect {|raw_key| ObjectSpace._id2ref(raw_key)}
  end

  def include?(key)
    super(key.__id__)
  end
end
end