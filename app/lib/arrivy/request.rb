class Arrivy::Request
  def self.get(path, params = {})
    request(:get, path, params)
  end

  def self.post(path, params = {})
    request(:post, path, params)
  end

  def self.put(path, params = {})
    request(:put, path, params)
  end

  def self.delete(path, params = {})
    request(:delete, path, params)
  end

  def self.request(method, path, params = nil)
    url = File.join(endpoint, path)
    response = RestClient::Request.execute(
      method: method,
      url: url,
      payload: payload(params),
      headers: headers
    )
    return response
  end

  def self.endpoint
    Rails.secrets.dig(:arrivy, :endpoint)
  end

  def self.auth_key
    Rails.secrets.dig(:arrivy, :auth_key)
  end

  def self.auth_token
    Rails.secrets.dig(:arrivy, :auth_token)
  end

  def self.headers
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Auth-Key' => auth_key,
      'X-Auth-Token' => auth_token,
    }
  end

  def self.payload(params)
    !params.empty? && params.try(:to_json)
  end
end
