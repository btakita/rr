class Range
  def wildcard_match?(other)
    return true if self == other
    return false unless other.is_a?(Numeric)
    self.include?(other)
  end
end
