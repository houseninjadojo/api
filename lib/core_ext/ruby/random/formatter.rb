# Generate random alphabetic string (a-z)
#
# @example
#   SecureRandom.alphabetic      => "qfwkgsnzfmyogyya"
#   SecureRandom.alphabetic(10)  => "eugdcvyqsi"
module Random::Formatter
  def alphabetic(n = 16)
    choose([*'a'..'z'], n)
  end
end
