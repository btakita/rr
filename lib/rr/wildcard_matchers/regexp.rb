class Regexp
  def wildcard_match?(other)
    return true if self == other
    return false unless other.is_a?(String)
    (other =~ self) ? true : false
  end
end
