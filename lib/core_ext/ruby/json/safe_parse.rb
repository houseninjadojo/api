module JSON
  # Safely parse JSON without raising an exception
  #
  # @example
  #   JSON.safe_parse("not_json") #=> nil
  #   JSON.safe_parse('{ "some": "json" }') #=> { "some" => "json" }
  #
  # @param [String] json
  # @param [Hash] options
  # @return [Hash, Array, String, Integer, Float, true, false, nil]
  def self.safe_parse(json, options = {})
    begin
      ::JSON.parse(json, options)
    rescue ::JSON::ParserError
      nil
    end
  end
end
