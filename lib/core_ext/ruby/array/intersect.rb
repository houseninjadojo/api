class Array
  # Returns true if the array and the given array have at least one element in common.
  #
  # @example
  #   [1, 2, 3].intersect? [3, 4, 5] #=> true
  #   [1, 2, 3].intersect? [4, 5, 6] #=> false
  #
  # @param [Array] arr
  # @return [Boolean]
  def intersect?(arr)
    return false unless arr.is_a?(Array)
    self.to_set.intersect?(arr.to_set)
  end
end
